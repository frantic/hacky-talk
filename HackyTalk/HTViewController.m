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
    NSMutableArray *friend_ids;
}

@synthesize firstNameLabel;
@synthesize lastNameLabel;
@synthesize profilePicture;
@synthesize spinner;
@synthesize connectionStatus;
@synthesize friendsButtons;
@synthesize talkDurationLabel;
@synthesize speakerFirstNameLabel;
@synthesize speakerLastNameLabel;
@synthesize speakerImage;
@synthesize speakerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"HackyTalk";
        audio = [[HTAudio alloc] init];
        audio.delegate = self;
        api = [HTAPI api];
        api.delegate = self;
        friend_ids = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", nil];
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
    talkDurationLabel.layer.cornerRadius = 5;
    speakerView.hidden = YES;
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
    [api sendAudioData:[audio recordedData] to:friend_ids];
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
    speakerFirstNameLabel.text = @"Incoming message...";
    speakerLastNameLabel.text = user;
    for (NSDictionary *d in api.friendsArray) {
        if ([user isEqualToString:[d objectForKey:@"id"]]) {
            speakerLastNameLabel.text = [d objectForKey:@"name"];
            break;
        }
    }
    talkDurationLabel.text = [NSString stringWithFormat:@"%.1f s", audio.player.duration];
    speakerView.hidden = NO;
}

- (void)audioDidFinishPlaying
{
    speakerView.hidden = YES;
}

- (void)viewDidUnload {
    [self setFirstNameLabel:nil];
    [self setLastNameLabel:nil];
    [self setProfilePicture:nil];
    [self setSpinner:nil];
    [self setConnectionStatus:nil];
    [self setFriendsButtons:nil];
    [self setTalkDurationLabel:nil];
    [self setSpeakerFirstNameLabel:nil];
    [self setSpeakerLastNameLabel:nil];
    [self setSpeakerImage:nil];
    [self setSpeakerView:nil];
    [super viewDidUnload];
}

- (void)setFriend:(NSDictionary *)f forButton:(UIButton *)b
{
    if (f) {
        b.layer.borderWidth = 2;
        b.layer.borderColor = [[UIColor whiteColor] CGColor];
        NSString *friend_id = [[NSString alloc] initWithString:[f objectForKey:@"id"]];
        [b setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", friend_id]]]] forState:UIControlStateNormal];
        [friend_ids replaceObjectAtIndex:b.tag withObject:friend_id];
    } else {
        b.layer.borderWidth = 0;
        [friend_ids replaceObjectAtIndex:b.tag withObject:@""];
        [b setImage:[UIImage imageNamed:@"add-person"] forState:UIControlStateNormal];
    }
    NSLog(@"%@", friend_ids);
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
