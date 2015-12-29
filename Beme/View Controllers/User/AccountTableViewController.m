//
//  AccountTableViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "AccountTableViewController.h"
#import <Parse/Parse.h>

#import "SettingsTableViewController.h"
#import "FindFriendsTableViewController.h"
#import "FollowerTableViewController.h"
#import "FollowingTableViewController.h"

#import "FontAwesomeKit/FAKIonIcons.h"

typedef NS_ENUM(NSInteger, AccountRows) {
    FIND_FRIENDS_ROW,
    FOLLOWING_ROW,
    FOLLOWERS_ROW,
    
    NUMBER_OF_ROWS,
};

@interface AccountTableViewController ()

@end

@implementation AccountTableViewController

- (void)commonInit{
    [super commonInit];
    
    self.title = [PFUser currentUser].username.uppercaseString;
    
    // setup dismiss button for modal!
    [self setupLeftModalDismissButton];
    
    FAKIonIcons *icon = [FAKIonIcons iosGearIconWithSize:25];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[icon imageWithSize:CGSizeMake(25, 25)] style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)]];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];

    switch (indexPath.row) {
        case FIND_FRIENDS_ROW: {
            cell.textLabel.text = @"Find friends";

            break;
        }
            
        case FOLLOWING_ROW: {
            cell.textLabel.text = @"Following";
            
            break;
        }
            
        case FOLLOWERS_ROW: {
            cell.textLabel.text = @"Followers";
            
            break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id viewController;
    
    switch (indexPath.row) {
        case FIND_FRIENDS_ROW: {
            viewController = [FindFriendsTableViewController new];
            break;
        }
            
        case FOLLOWING_ROW: {
            viewController = [FollowingTableViewController new];
            break;
        }
            
        case FOLLOWERS_ROW: {
            viewController = [FollowerTableViewController new];
            break;
        }
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return NUMBER_OF_ROWS;
}

#pragma mark - Actions

- (void)showSettings{
    [self.navigationController pushViewController:[SettingsTableViewController new] animated:YES];
}

@end
