//
//  HTPeoplePickerViewController.h
//  HackyTalk
//
//  Created by Frantic on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HTSelectedFreindBlock)(NSDictionary *selectedFriend);

@interface HTPeoplePickerViewController : UITableViewController <FBRequestDelegate> {
    
}

@property (nonatomic, copy) HTSelectedFreindBlock delegateBlock;

@end
