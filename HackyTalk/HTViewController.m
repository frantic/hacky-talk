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
        self.navigationItem.title = @"HackyTalk";
        audio = [[HTAudio alloc] init];
        api = [HTAPI api];
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
    [api sendAudioData:[audio recordedData] to:@"123"];
    [audio play];
}

- (IBAction)ping:(id)sender
{

}

- (IBAction)selectFriend:(id)sender
{
    HTPeoplePickerViewController *peoplePicker = [[HTPeoplePickerViewController alloc] init];
    [self.navigationController pushViewController:peoplePicker animated:YES];
}

- (IBAction)logIn:(id)sender
{
    [api signInWithID:@"frantic"];
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    NSLog(@"Result = %@", result);
}

@end
