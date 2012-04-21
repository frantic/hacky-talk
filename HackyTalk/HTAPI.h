//
//  HTAPI.h
//  HackyTalk
//
//  Created by Frantic on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "FBConnect.h"
#import "HTAppDelegate.h"
#import "JSON.h"

@interface HTAPI : NSObject <GCDAsyncSocketDelegate> {
    GCDAsyncSocket *socket;
}

@property (nonatomic, readonly) BOOL isConnected;
@property (nonatomic, readonly) Facebook *fb;

+ (HTAPI *)api;
- (void)signInWithID:(NSString *)userId;
- (void)sendAudioData:(NSData *)data to:(NSString *)user;

@end
