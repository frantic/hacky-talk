//
//  HTAPI.m
//  HackyTalk
//
//  Created by Frantic on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HTAPI.h"

#define FOREVER -1

typedef struct {
    Byte facebook;
    Byte command;
    UInt32 size;
} HTPacketHeader;

@implementation HTAPI

@synthesize isConnected = _isConnected;

- (void)signInWithID:(NSString *)userId
{
    NSError *error = nil;
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_current_queue()];
    [socket connectToHost:@"172.16.0.62" onPort:8888 withTimeout:FOREVER error:&error];
    if (error) {
        NSLog(@"Something really strange have happened during socket init %@", error);
    } else {
        HTPacketHeader loginHeader;
        loginHeader.facebook = 0xfb;
        loginHeader.command = 0x01;
        loginHeader.size = [userId lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        NSData *headerData = [NSData dataWithBytes:&loginHeader length:sizeof(loginHeader)];
        [socket writeData:headerData withTimeout:FOREVER tag:0];
        [socket writeData:[userId dataUsingEncoding:NSUTF8StringEncoding] withTimeout:FOREVER tag:0x01];
    }
}

- (void)sendAudioData:(NSData *)data to:(NSString *)user
{
    HTPacketHeader audioHeader;
    audioHeader.facebook = 0xfb;
    audioHeader.command = 0x02;
    audioHeader.size = [data length];
    NSData *headerData = [NSData dataWithBytes:&audioHeader length:sizeof(audioHeader)];
    [socket writeData:headerData withTimeout:FOREVER tag:0x02];
    [socket writeData:data withTimeout:FOREVER tag:0x02];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"Connection esteblished");
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"Disconnected %@!", err);
    _isConnected = NO;
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == 0x01) {
        _isConnected = YES;
        NSLog(@"Login packet sent");
    }
}

@end
