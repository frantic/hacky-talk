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
@synthesize connectButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"HackyTalk";
        audio = [[HTAudio alloc] init];
        api = [HTAPI api];
        api.delegate = self;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [api.fb requestWithGraphPath:@"me" andDelegate:self];
}

- (IBAction)startRecording:(id)sender
{
    [audio startRecording];
}

- (IBAction)stopRecording:(id)sender
{
    [self performSelector:@selector(delayedStop) withObject:nil afterDelay:0.5];
}

- (void)delayedStop
{
    [audio stopRecording];
    [api sendAudioData:[audio recordedData] to:@"123"];
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

- (IBAction)connectFacebook:(id)sender
{
    [api.fb authorize:nil];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    NSLog(@"ME: %@", result);
}

- (void)incomingAudioData:(NSData *)data from:(NSString *)user
{
    [audio playData:data];
}

- (void)viewDidUnload {
    [self setConnectButton:nil];
    [super viewDidUnload];
}

@end
