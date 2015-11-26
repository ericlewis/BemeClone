//
//  FollowingTableViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "FollowingTableViewController.h"

@interface FollowingTableViewController ()

@end

@implementation FollowingTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"FOLLOWING";
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self loadObjects];
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable{
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kActivityClassKey];
    [followingActivitiesQuery whereKey:kActivityTypeKey equalTo:kActivityTypeFollow];
    [followingActivitiesQuery whereKey:kActivityFromUserKey equalTo:[PFUser currentUser]];
    
    return followingActivitiesQuery;
}


#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    UserFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UserFollowCell class])];
    
    // user
    PFUser *user = [[object objectForKey:@"toUser"] fetchIfNeeded];
    
    [cell setUser:user followers:NO];
    
    return cell;
}

@end
