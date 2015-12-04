//
//  UserFollowCell.h
//  Beme
//
//  Created by Eric Lewis on 11/25/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol UserFollowCellDelegate;

@interface UserFollowCell : UITableViewCell

@property (nonatomic, strong) id<UserFollowCellDelegate> delegate;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UIButton *followButton;

- (void)setUser:(PFUser *)user followers:(BOOL)isFollowers;
- (void)setFollowing:(BOOL)isFollowing;

@end

@protocol UserFollowCellDelegate <NSObject>
@optional

- (void)cell:(UserFollowCell *)cell didTapFollowButton:(PFUser *)user;

@end
