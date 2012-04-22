//
//  HTAudio.m
//  HackyTalk
//
//  Created by Frantic on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HTAudio.h"

@implementation HTAudio

@synthesize player = _player;
@synthesize recorder = _recorder;

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
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:soundURL settings:recorderParams error:&error];
        if (error) {
            NSLog(@"Something went wrong with aodio: %@", error);
        } else {
            if ([_recorder prepareToRecord])
                NSLog(@"Recorder is ready!");
            else
                NSLog(@"Recorder can't be prepared to recording");
        }
    }
    return self;
}

- (void)startRecording
{
    [_recorder deleteRecording];
    [_recorder record];
    NSLog(@"Recording...");
}

- (void)stopRecording
{
    [_recorder stop];
    NSLog(@"Recorded!");
}

- (void)play
{
    [self playFile:_recorder.url.path];
}

- (void)playData:(NSData *)data
{
    [data writeToURL:_recorder.url atomically:YES];
    [self play];
}

- (void)playFile:(NSString *)file
{
    if (_player.isPlaying) {
        NSLog(@"Player is busy");
    } else {
        NSError *error = nil;
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:file] error:&error];
        if (error)
            NSLog(@"Can't play file %@: %@", file, error);
        else {
            NSLog(@"Playing %f record", [_player duration]);
            [_player play];
        }
    }
}

- (NSData *)recordedData
{
    return [NSData dataWithContentsOfURL:_recorder.url];
}

@end
