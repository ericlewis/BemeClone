//
//  BaseTableViewController.h
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import "CommonViewHeaders.h"

@interface BaseTableViewController : UITableViewController

- (void)commonInit;
- (void)setupRefreshControl;
- (void)refreshData;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end
