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
    HTAudio *audio;
    HTAPI *api;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        audio = [[HTAudio alloc] init];
        api = [[HTAPI alloc] init];
        [api signInWithID:@"frantic"];
    }
    return self;
}

- (IBAction)startRecording:(id)sender
{
    [audio startRecording];
}

- (IBAction)stopRecording:(id)sender
{
    [audio stopRecording];
    [audio play];
}

- (IBAction)ping:(id)sender
{
    [api.fb requestWithGraphPath:@"me/friends" andDelegate:self];
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    NSLog(@"Result = %@", result);
}

@end
