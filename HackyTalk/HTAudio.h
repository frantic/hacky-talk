//
//  HTAudio.h
//  HackyTalk
//
//  Created by Frantic on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol HTAudioDelegate <NSObject>

- (void)audioDidFinishPlaying;

@end

@interface HTAudio : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, strong, readonly) AVAudioRecorder *recorder;
@property (nonatomic, strong, readonly) AVAudioPlayer *player;
@property (weak, nonatomic) id<HTAudioDelegate> delegate;

- (NSData *)recordedData;
- (void)startRecording;
- (void)stopRecording;
- (void)play;
- (void)playFile:(NSString *)file;
- (void)playData:(NSData *)data;

@end
