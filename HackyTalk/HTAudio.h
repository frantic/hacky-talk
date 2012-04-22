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

@property (nonatomic, readonly) AVAudioRecorder *recorder;
@property (nonatomic, readonly) AVAudioPlayer *player;

- (NSData *)recordedData;
- (void)startRecording;
- (void)stopRecording;
- (void)play;
- (void)playFile:(NSString *)file;
- (void)playData:(NSData *)data;

@end
