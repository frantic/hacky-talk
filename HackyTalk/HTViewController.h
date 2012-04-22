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

@property (weak, nonatomic) IBOutlet UIButton *connectButton;

- (IBAction)startRecording:(id)sender;
- (IBAction)stopRecording:(id)sender;

- (IBAction)ping:(id)sender;
- (IBAction)selectFriend:(id)sender;
- (IBAction)logIn:(id)sender;
- (IBAction)connectFacebook:(id)sender;

@end
