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
    NSUInteger size;
} HTPacketHeader;

@interface HTAPI (Private)

- (void)fireJSON:(NSDictionary *)dict;

@end

@implementation HTAPI

@synthesize isConnected = _isConnected;

static HTAPI *_sharedInstance = nil;

+ (HTAPI *)api
{
    if (_sharedInstance == nil)
        _sharedInstance = [[HTAPI alloc] init];
    return _sharedInstance;
}

- (void)signInWithID:(NSString *)userId
{
    NSError *error = nil;
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_current_queue()];
    [socket connectToHost:@"172.16.0.62" onPort:8888 withTimeout:FOREVER error:&error];
    if (error) {
        NSLog(@"Something really strange have happened during socket init %@", error);
    } else {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:@"auth" forKey:@"cmd"];
        [params setObject:userId forKey:@"id"];
        [self fireJSON:params];
    }
}

- (void)sendAudioData:(NSData *)data to:(NSString *)user
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"send" forKey:@"cmd"];
    [params setObject:[NSNumber numberWithInt:[data length]] forKey:@"size"];
    [socket writeData:data withTimeout:FOREVER tag:0x02];
}

- (void)fireJSON:(NSDictionary *)dict
{
    
    NSString *json = [dict JSONRepresentation];
    NSLog(@"JSON >> %@", json);
    NSData *data = [[json stringByAppendingString:@"\0"] dataUsingEncoding:NSUTF8StringEncoding];
    [socket writeData:data withTimeout:FOREVER tag:0];
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

- (Facebook *)fb
{
    return [(HTAppDelegate *)[[UIApplication sharedApplication] delegate] facebook];
}

@end
