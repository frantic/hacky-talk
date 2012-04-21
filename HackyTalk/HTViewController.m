//
//  HTViewController.m
//  HackyTalk
//
//  Created by Frantic on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HTViewController.h"

@interface HTViewController ()

@end

@implementation HTViewController {
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [docPath stringByAppendingPathComponent:@"myfile.caf"];
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
            NSLog(@"Something went wrong: %@", error);
        } else {
            if ([recorder prepareToRecord])
                NSLog(@"Recorder is ready!");
            else
                NSLog(@"Oops");
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)startRecording:(id)sender
{
    NSLog(@"Starting record");
    [recorder record];
    NSLog(@"Recording...");
}

- (IBAction)stopRecording:(id)sender
{
    NSLog(@"Stopping record");
    [recorder stop];
    NSLog(@"Stopped");
    NSDictionary *fileAttrs = [[NSFileManager defaultManager] attributesOfItemAtPath:recorder.url.path error:nil];
    NSError *error = nil;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:&error];
    if (error)
        NSLog(@"Can't play %@", error);
    else {
        NSLog(@"File size = %lld for duration: %f", [fileAttrs fileSize], player.duration);
        [player play];
        NSLog(@"Playing...");
    }
}

@end
