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

@interface HTAPI (Private)

- (void)fireJSON:(NSDictionary *)dict;
- (void)fireBLOB:(NSData *)blob;
- (void)waitForJson;
- (void)waitForBlob:(NSInteger)size;

@end

@implementation HTAPI

@synthesize delegate = _delegate;

static HTAPI *_sharedInstance = nil;
static NSData *_zero = nil;

+ (HTAPI *)api
{
    if (_sharedInstance == nil) {
        _sharedInstance = [[HTAPI alloc] init];
        Byte n = 0;
        _zero = [NSData dataWithBytes:&n length:1];
    }
    return _sharedInstance;
}

- (void)signInWithID:(NSString *)userId
{
    NSError *error = nil;
    if (![socket isConnected]) {
        socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_current_queue()];
        [socket connectToHost:@"172.16.0.62" onPort:8888 withTimeout:FOREVER error:&error];
        [self waitForJson];
    }
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
    [self fireJSON:params];
    [self fireBLOB:data];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if (tag == TAG_HEADER) {
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@">> %@", json);
        NSDictionary *params = [json JSONValue];
        NSInteger size = [[params objectForKey:@"size"] integerValue];
        [self waitForBlob:size];
    } else if (tag == TAG_BLOB) {
        NSLog(@">> [BLOB] %d bytes", [data length]);
        [self.delegate incomingAudioData:data from:@"123"];
        [self waitForJson];
    }
}

- (void)fireJSON:(NSDictionary *)dict
{
    NSString *json = [dict JSONRepresentation];
    NSLog(@"<< %@", json);
    NSData *data = [[json stringByAppendingString:@"\0"] dataUsingEncoding:NSUTF8StringEncoding];
    [socket writeData:data withTimeout:FOREVER tag:0];
}

- (void)fireBLOB:(NSData *)blob
{
    NSLog(@"<< [BLOB] %d bytes", [blob length]);
    [socket writeData:blob withTimeout:FOREVER tag:0];
}

- (void)waitForJson
{
    [socket readDataToData:_zero withTimeout:FOREVER tag:TAG_HEADER];
}

- (void)waitForBlob:(NSInteger)size
{
    [socket readDataToLength:size withTimeout:FOREVER tag:TAG_BLOB];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"Connection esteblished");
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"Disconnected %@!", err);
}

- (Facebook *)fb
{
    return [(HTAppDelegate *)[[UIApplication sharedApplication] delegate] facebook];
}

- (BOOL)isConnected
{
    return [socket isConnected];
}

@end
