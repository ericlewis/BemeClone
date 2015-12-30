//
//  FollowerTableViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "FollowerTableViewController.h"

@interface FollowerTableViewController ()

@end

@implementation FollowerTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"RECENT FOLLOWERS";
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self loadObjects];
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable{
    PFQuery *followerActivitiesQuery = [PFQuery queryWithClassName:kActivityClassKey];
    [followerActivitiesQuery whereKey:kActivityTypeKey equalTo:kActivityTypeFollow];
    [followerActivitiesQuery whereKey:kActivityToUserKey equalTo:[PFUser currentUser]];
    
    [followerActivitiesQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];

    return followerActivitiesQuery;
}


#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    UserFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UserFollowCell class])];
    
    // user
    PFUser *user = [[object objectForKey:@"fromUser"] fetchIfNeeded];
    
    [cell setUser:user followers:YES];
    cell.delegate = self;
    
    return cell;
}

@end
