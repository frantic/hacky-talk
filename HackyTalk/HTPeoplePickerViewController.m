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
    NSArray *friends;
}

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
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    self.navigationItem.title = @"Select a friend";
    [api.fb requestWithGraphPath:@"me/friends" andDelegate:self];
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    friends = [result objectForKey:@"data"];
    NSLog(@"Got %d friends: %@", [friends count], result);
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
    return [friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.textLabel.text = [[friends objectAtIndex:[indexPath row]] objectForKey:@"name"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
