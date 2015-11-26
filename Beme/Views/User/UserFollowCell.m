//
//  UserFollowCell.m
//  Beme
//
//  Created by Eric Lewis on 11/25/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "UserFollowCell.h"
#import "Cache.h"

@implementation UserFollowCell

- (void)setUser:(PFUser *)user followers:(BOOL)isFollowers{
    // cache data
    NSDictionary *attributes = [[Cache sharedCache] attributesForUser:user];
    
    // set follow status if we have a cache
    if (attributes) {
        [self setFollowing:[[Cache sharedCache] followStatusForUser:user]];

    }else{
        @synchronized(self) {
            PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kActivityClassKey];
            [isFollowingQuery whereKey:kActivityTypeKey equalTo:kActivityTypeFollow];
            
            if (isFollowers) {
                [isFollowingQuery whereKey:kActivityFromUserKey equalTo:user];
                [isFollowingQuery whereKey:kActivityToUserKey equalTo:[PFUser currentUser]];
            }else{
                [isFollowingQuery whereKey:kActivityToUserKey equalTo:user];
                [isFollowingQuery whereKey:kActivityFromUserKey equalTo:[PFUser currentUser]];
            }
            
            [isFollowingQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
            
            [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                @synchronized(self) {
                    [[Cache sharedCache] setFollowStatus:(!error && number > 0) user:user];
                }
                
                [self setFollowing:(!error && number > 0)];
            }];
            
        }
    }
    
    self.textLabel.text = user.username;

}

- (void)setFollowing:(BOOL)isFollowing{
    if (isFollowing) {
        [self setBackgroundColor:[UIColor blueColor]];

    }else{
        [self setBackgroundColor:[UIColor whiteColor]];

    }
}

@end
