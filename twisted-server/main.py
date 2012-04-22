#!/bin/python

from twisted.internet import reactor, protocol
from protocol import HackyTalkFactory

if __name__ == "__main__":
    
    factory = HackyTalkFactory()
    
    reactor.listenTCP(8888, factory)
    print "Starting listening"
    reactor.run()
    print "Stop working"