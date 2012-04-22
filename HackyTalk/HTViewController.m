//
//  HTViewController.m
//  HackyTalk
//
//  Created by Frantic on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HTViewController.h"

@interface HTViewController ()

@end

@implementation HTViewController {
    HTAudio *audio;
    HTAPI *api;
    BOOL profileIsLoaded;
}

@synthesize firstNameLabel;
@synthesize lastNameLabel;
@synthesize profilePicture;
@synthesize spinner;
@synthesize connectionStatus;
@synthesize friendsButtons;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"HackyTalk";
        audio = [[HTAudio alloc] init];
        api = [HTAPI api];
        api.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFacebookData) name:@"fbDidLogin" object:nil];
    }
    return self;
}

- (void)loadFacebookData
{
    [api.fb requestWithGraphPath:@"me" andDelegate:self];
    firstNameLabel.text = @"Please, wait...";
    lastNameLabel.text = @"Signing into Facebook";
    profilePicture.hidden = YES;
    connectionStatus.hidden = YES;
    spinner.hidden = NO;
    [self onlineStatusChangedTo:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    profilePicture.layer.borderWidth = 2;
    profilePicture.layer.borderColor = [[UIColor whiteColor] CGColor];
    profilePicture.layer.cornerRadius = 4;
    profilePicture.clipsToBounds = YES;
    connectionStatus.layer.cornerRadius = 2;
    for (UIButton *b in friendsButtons) {
        b.clipsToBounds = YES;
        b.layer.cornerRadius = 10;
    }
    [self loadFacebookData];
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

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    [api.fb authorize:nil];
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    firstNameLabel.text = [result objectForKey:@"first_name"];
    lastNameLabel.text = [result objectForKey:@"last_name"];
    profilePicture.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", [result objectForKey:@"id"]]]]];
    profilePicture.hidden = NO;
    connectionStatus.hidden = NO;
    spinner.hidden = YES;
    [api signInWithID:[result objectForKey:@"id"]];
    NSLog(@"ME: %@", result);
}

- (void)onlineStatusChangedTo:(BOOL)connected
{
    connectionStatus.backgroundColor = connected ? [UIColor greenColor] : [UIColor redColor];
}

- (void)incomingAudioData:(NSData *)data from:(NSString *)user
{
    [audio playData:data];
}

- (void)viewDidUnload {
    [self setFirstNameLabel:nil];
    [self setLastNameLabel:nil];
    [self setProfilePicture:nil];
    [self setSpinner:nil];
    [self setConnectionStatus:nil];
    [self setFriendsButtons:nil];
    [super viewDidUnload];
}

- (void)setFriend:(NSDictionary *)f forButton:(UIButton *)b
{
    if (f) {
        b.layer.borderWidth = 2;
        b.layer.borderColor = [[UIColor whiteColor] CGColor];
        [b setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", [f objectForKey:@"id"]]]]] forState:UIControlStateNormal];
    } else {
        b.layer.borderWidth = 0;
        [b setImage:[UIImage imageNamed:@"add-person"] forState:UIControlStateNormal];
    }
}

- (IBAction)tapFriend:(id)sender
{
    HTPeoplePickerViewController *c = [[HTPeoplePickerViewController alloc] init];
    [c setDelegateBlock:^(NSDictionary *f) {
        [self setFriend:f forButton:sender];
    }];
    [self.navigationController pushViewController:c animated:YES];
}

- (IBAction)tapOutFriend:(id)sender
{
    [self setFriend:nil forButton:sender];
}

@end
