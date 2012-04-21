//
//  HTAudio.h
//  HackyTalk
//
//  Created by Frantic on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface HTAudio : NSObject

- (void)startRecording;
- (void)stopRecording;
- (void)play;
- (void)playFile:(NSString *)file;

@end
