//
//  UserFollowCell.h
//  Beme
//
//  Created by Eric Lewis on 11/25/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface UserFollowCell : UITableViewCell

@property (nonatomic, strong) PFUser *user;

- (void)setUser:(PFUser *)user;

@end
