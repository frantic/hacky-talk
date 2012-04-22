//
//  HTViewController.h
//  HackyTalk
//
//  Created by Frantic on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTPeoplePickerViewController.h"
#import "HTAPI.h"
#import "HTAudio.h"

@interface HTViewController : UIViewController <FBRequestDelegate, HTAPIDelegate>

@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIView *connectionStatus;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *friendsButtons;

- (IBAction)startRecording:(id)sender;
- (IBAction)stopRecording:(id)sender;

- (IBAction)tapFriend:(id)sender;
- (IBAction)tapOutFriend:(id)sender;

@end
