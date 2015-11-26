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
    
    return followerActivitiesQuery;
}


#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    
    // user
    PFUser *user = [[object objectForKey:@"fromUser"] fetchIfNeeded];
    
    // cache data
    NSDictionary *attributes = [[Cache sharedCache] attributesForUser:user];
    
    // set follow status if we have a cache
    if (attributes) {
        if ([[Cache sharedCache] followStatusForUser:user]) {
            [cell setBackgroundColor:[UIColor blueColor]];
        }else{
            [cell setBackgroundColor:[UIColor whiteColor]];
        }
    }else{
        @synchronized(self) {
            PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kActivityClassKey];
            [isFollowingQuery whereKey:kActivityToUserKey equalTo:[PFUser currentUser]];
            [isFollowingQuery whereKey:kActivityTypeKey equalTo:kActivityTypeFollow];
            [isFollowingQuery whereKey:kActivityFromUserKey equalTo:user];
            [isFollowingQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
            
            [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                @synchronized(self) {
                    [[Cache sharedCache] setFollowStatus:(!error && number > 0) user:user];
                }
                if (cell.tag == indexPath.row) {
                    if (!error && number > 0) {
                        [cell setBackgroundColor:[UIColor blueColor]];

                    }else{
                        [cell setBackgroundColor:[UIColor whiteColor]];

                    }
                }
            }];
        }
    }

    cell.textLabel.text = user.username;
    
    return cell;
}

@end
