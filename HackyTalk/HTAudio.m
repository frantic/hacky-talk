//
//  HTAudio.m
//  HackyTalk
//
//  Created by Frantic on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HTAudio.h"

@implementation HTAudio {
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [docPath stringByAppendingPathComponent:@"buffer.aac"];
        NSURL *soundURL = [NSURL fileURLWithPath:filePath];
        
        NSMutableDictionary *recorderParams = [NSMutableDictionary dictionary];
        [recorderParams setObject:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
        [recorderParams setObject:[NSNumber numberWithInt:11025] forKey:AVSampleRateKey];
        
        [recorderParams setObject:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recorderParams setObject:[NSNumber numberWithInt:16] forKey:AVEncoderBitRateKey];
        [recorderParams setObject:[NSNumber numberWithInt:11025] forKey:AVEncoderBitRateKey];
        [recorderParams setObject:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
        
        NSError *error = nil;
        
        recorder = [[AVAudioRecorder alloc] initWithURL:soundURL settings:recorderParams error:&error];
        if (error) {
            NSLog(@"Something went wrong with aodio: %@", error);
        } else {
            if ([recorder prepareToRecord])
                NSLog(@"Recorder is ready!");
            else
                NSLog(@"Recorder can't be prepared to recording");
        }
    }
    return self;
}

- (void)startRecording
{
    [recorder record];
    NSLog(@"Recording...");
}

- (void)stopRecording
{
    [recorder stop];
    NSLog(@"Recorded!");
}

- (void)play
{
    [self playFile:recorder.url.path];
}

- (void)playFile:(NSString *)file
{
    if (player.isPlaying) {
        NSLog(@"Player is busy");
    } else {
        NSError *error = nil;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:file] error:&error];
        if (error)
            NSLog(@"Can't play file %@: %@", file, error);
        else {
            NSLog(@"Playing %f record", [player duration]);
            [player play];
        }
    }
}

- (NSData *)recordedData
{
    return [NSData dataWithContentsOfURL:recorder.url];
}

@end
