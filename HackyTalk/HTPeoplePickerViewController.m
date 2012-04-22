//
//  HTPeoplePickerViewController.m
//  HackyTalk
//
//  Created by Frantic on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HTPeoplePickerViewController.h"

@interface HTPeoplePickerViewController ()

@end

@implementation HTPeoplePickerViewController {
    HTAPI *api;
}

@synthesize delegateBlock;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        api = [HTAPI api];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Select a friend";
    if (!api.friendsArray) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [spinner startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
        [api.fb requestWithGraphPath:@"me/friends" andDelegate:self];
    }
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    api.friendsArray = [result objectForKey:@"data"];
    NSLog(@"Got %d friends: %@", [api.friendsArray count], result);
    self.navigationItem.rightBarButtonItem = nil;
    [self.tableView reloadData];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Request failed %@", error);
    [self.navigationController popViewControllerAnimated:YES];
    [[[UIAlertView alloc] initWithTitle:nil message:@"There was a problem loading your Facebook friends, sorry." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [api.friendsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.textLabel.text = [[api.friendsArray objectAtIndex:[indexPath row]] objectForKey:@"name"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegateBlock) {
        delegateBlock([api.friendsArray objectAtIndex:[indexPath row]]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
