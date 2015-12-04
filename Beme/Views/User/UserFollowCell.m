//
//  UserFollowCell.m
//  Beme
//
//  Created by Eric Lewis on 11/25/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "UserFollowCell.h"
#import "UIColor+Additions.h"
#import "Cache.h"

@interface UserFollowCell()
@end

@implementation UserFollowCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        self.followButton = [UIButton new];
        [self.followButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
        [self.followButton setTitle:@"UNFOLLOW" forState:UIControlStateSelected];
        [self.followButton setTitleColor:[UIColor commonForegroundColor] forState:UIControlStateNormal];
        [self.followButton addTarget:self action:@selector(didTapFollowButtonAction:)
                    forControlEvents:UIControlEventTouchUpInside];
        [self.followButton sizeToFit];
        
        self.accessoryView = self.followButton;
    }
    
    return self;
}

- (void)setUser:(PFUser *)user followers:(BOOL)isFollowers{
    self.user = user;
    
    // cache data
    NSDictionary *attributes = nil;
    //[[Cache sharedCache] attributesForUser:self.user]
    
    // set follow status if we have a cache
    if (attributes) {
        [self setFollowing:[[Cache sharedCache] followStatusForUser:self.user]];

    }else{
        @synchronized(self) {
            PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kActivityClassKey];
            [isFollowingQuery whereKey:kActivityTypeKey equalTo:kActivityTypeFollow];
            
            if (!isFollowers) {
                [isFollowingQuery whereKey:kActivityFromUserKey equalTo:self.user];
                [isFollowingQuery whereKey:kActivityToUserKey equalTo:[PFUser currentUser]];
            }else{
                [isFollowingQuery whereKey:kActivityToUserKey equalTo:self.user];
                [isFollowingQuery whereKey:kActivityFromUserKey equalTo:[PFUser currentUser]];
            }
            
            [isFollowingQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
            
            [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                @synchronized(self) {
                    [[Cache sharedCache] setFollowStatus:(!error && number > 0) user:self.user];
                }
                
                [self setFollowing:(!error && number > 0)];
            }];
            
        }
    }
    
    self.textLabel.text = self.user.username;

}

- (void)setFollowing:(BOOL)isFollowing{
    if (isFollowing) {
        self.followButton.selected = YES;
        [self.followButton sizeToFit];
        
    }else{
        self.followButton.selected = NO;
        [self.followButton sizeToFit];

    }
}

- (void)didTapFollowButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapFollowButton:)]) {
        [self.delegate cell:self didTapFollowButton:self.user];
    }
}

@end
