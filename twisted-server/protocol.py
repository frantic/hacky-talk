from twisted.internet.protocol import Protocol, Factory
from json import loads, dumps
from time import time

class HackyTalkProtocol(Protocol):  

    def __init__(self, factory):
        self.factory = factory
        self.is_reading = False
        self.buffer = ""
        self.buffer_size = 0
        self.user_id = ""
        self.user_ip = ""
        self.friends_list = []

    def connectionMade(self):
        self.user_ip = self.transport.getPeer().host
        print "User %s connected" % self.user_ip

    def connectionLost(self, reason):
        self.factory.removeUser(self)
        print 'User %s. Connection Lost. Reason - %s' % (self.user_id, reason.getErrorMessage())

    def dataReceived(self, data):
        # if we are reading stream now
        if not self.is_reading:
            # if it's not full command
            if not '\0' in data:
                self.buffer += data
                return

            last_null = -1
            # seeking for null char and deviding data into commands
            for index in xrange(len(data)):
                if data[index] == '\0':
                    self.buffer += data[last_null + 1 : index]
                    last_null = index
                    # process command and check for reading from stream
                    if self.parseCommand(self.buffer):
                        self.buffer = data[last_null + 1:]
                        self.is_reading = True
                        break;
                    else:
                        self.buffer = ""
        else:
            # reading sream
            self.buffer += data
            if len(self.buffer) < self.buffer_size:
                return
            # if stream had been loaded
            else:
                rest = ""
                if len(self.buffer) > self.buffer_size:
                    rest = self.buffer[self.buffer_size : ]
                # sending message to friends list
                self.factory.sendMessage(self, self.buffer[:self.buffer_size], self.friends_list)
                # clearing data
                self.is_reading = False
                self.buffer = ""
                self.buffer_size = 0
                self.friends_list = []
                # if we receive more data than expected
                if len(rest) > 0:
                    self.dataReceived(rest)

    def parseCommand(self, command):
        print "Command: %s" % command
        json_command = loads(command)
        cmd = json_command['cmd']
        # authentification command
        if cmd == 'auth':
            self.user_id = json_command['id']
            print "Auth by %s (%s)" % (self.user_id, self.user_ip)
            # adding user to active users list
            self.factory.addUser(self)
            # false means "do not read stream after command"
            return False
        # send message command
        elif cmd == 'send':
            self.buffer_size = json_command['size']
            if 'list' in json_command:
                self.friends_list = json_command['list']
            else:
                self.friends_list = ['100001244322535', '100003594243800']
            print "Receiving data! Size: %d" % self.buffer_size 
            if self.buffer_size > 0:
                # true means - read stream after this command
                return True

    def sendReceiveMessage(self, message):
        # sending message with flag "receive"
        receive_cmd = {}
        receive_cmd['cmd'] = 'receive'
        self.sendMessage(receive_cmd, message)

    def sendMissedMessage(self, message):
        # sending message with flag "missed"
        missed_cmd = {}
        missed_cmd['cmd'] = 'missed'
        self.sendMessage(missed_cmd, message)

    def sendMessage(self, cmd, message):
        # Sending json command
        data, from_id, time = message
        cmd['size'] = len(data)
        cmd['id'] = from_id
        cmd['time'] = time
        self.transport.write(dumps(cmd) + '\0')
        # Sening data
        self.transport.write(data)
        print "    Data(size: %d) is sended to %s(ip: %s)" % (len(data), self.user_id, self.user_ip)

class HackyTalkFactory(Factory):

    def __init__(self):
        self.users = {}
        self.missed_messages = {}

    def buildProtocol(self, addr):
        return HackyTalkProtocol(self)

    def addUser(self, user):
        # adding to active users list
        self.users[user.user_id] = user
        # if this user has missed messages - send them
        if user.user_id in self.missed_messages:
            print 'Getting messages from missed'
            for message in self.missed_messages[user.user_id]:
                user.sendMissedMessage(message)
            del self.missed_messages[user.user_id]

    def removeUser(self, user):
        # removing user from active users
        if user.user_id in self.users:
            del self.users[user.user_id]

    def sendMessage(self, sender, data, users_list):
        message = (data, sender.user_id, time())
        # sends message to all users in users_list
        for user_id in users_list:
            # if in active users list - send immediately
            if user_id in self.users:
                self.users[user_id].sendReceiveMessage(message)
            # if user not online - move message to missed list
            else:
                print 'Placing message to missed messages'
                if not user_id in self.missed_messages:
                    self.missed_messages[user_id] = []
                self.missed_messages[user_id].append(message)