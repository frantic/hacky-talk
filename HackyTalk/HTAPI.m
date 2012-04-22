//
//  HTAPI.m
//  HackyTalk
//
//  Created by Frantic on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HTAPI.h"

#define FOREVER -1
#define TAG_HEADER 1
#define TAG_BLOB 2

typedef struct {
    Byte facebook;
    Byte command;
    NSUInteger size;
} HTPacketHeader;

@interface HTAPI (Private)

- (void)fireJSON:(NSDictionary *)dict;

@end

@implementation HTAPI {
    NSData *zero;
}

@synthesize isConnected = _isConnected;
@synthesize delegate = _delegate;

static HTAPI *_sharedInstance = nil;

+ (HTAPI *)api
{
    if (_sharedInstance == nil)
        _sharedInstance = [[HTAPI alloc] init];
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        Byte n = 0;
        zero = [NSData dataWithBytes:&n length:1];
    }
    return self;
}

- (void)signInWithID:(NSString *)userId
{
    NSError *error = nil;
    if (![socket isConnected]) {
        socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_current_queue()];
        [socket connectToHost:@"172.16.0.62" onPort:8888 withTimeout:FOREVER error:&error];
    }
    if (error) {
        NSLog(@"Something really strange have happened during socket init %@", error);
    } else {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:@"auth" forKey:@"cmd"];
        [params setObject:userId forKey:@"id"];
        [self fireJSON:params];
        [socket readDataToData:zero withTimeout:FOREVER tag:TAG_HEADER];
    }
}

- (void)sendAudioData:(NSData *)data to:(NSString *)user
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"send" forKey:@"cmd"];
    [params setObject:[NSNumber numberWithInt:[data length]] forKey:@"size"];
    [self fireJSON:params];
    [socket writeData:data withTimeout:FOREVER tag:0x02];
}

- (void)fireJSON:(NSDictionary *)dict
{
    
    NSString *json = [dict JSONRepresentation];
    NSLog(@"JSON >> %@", json);
    NSData *data = [[json stringByAppendingString:@"\0"] dataUsingEncoding:NSUTF8StringEncoding];
    [socket writeData:data withTimeout:FOREVER tag:TAG_HEADER];
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

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"Incoming data size = %d", [data length]);
    if (tag == TAG_HEADER) {
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"And this is json %@", json);
        NSDictionary *params = [json JSONValue];
        NSInteger size = [[params objectForKey:@"size"] integerValue];
        [socket readDataToLength:size withTimeout:FOREVER tag:TAG_BLOB];
    } else if (tag == TAG_BLOB) {
        NSLog(@"And this is blob");
        [self.delegate incomingAudioData:data from:@"123"];
        [socket readDataToData:zero withTimeout:FOREVER tag:TAG_HEADER];
    }
}

- (Facebook *)fb
{
    return [(HTAppDelegate *)[[UIApplication sharedApplication] delegate] facebook];
}

@end
