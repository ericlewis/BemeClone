//
//  BaseFollowTableViewController.h
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "Utility.h"
#import "Cache.h"
#import <ParseUI/ParseUI.h>

#import "UserFollowCell.h"

@interface BaseFollowTableViewController : PFQueryTableViewController <UserFollowCellDelegate>

@end
