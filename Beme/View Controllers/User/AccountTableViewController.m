//
//  AccountTableViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "AccountTableViewController.h"
#import <Parse/Parse.h>

typedef NS_ENUM(NSInteger, AccountRows) {
    FIND_FRIENDS_ROW,
    FOLLOWING_ROW,
    FOLLOWERS_ROW,
    SETTINGS_ROW,
    
    NUMBER_OF_ROWS,
};

@interface AccountTableViewController ()

@end

@implementation AccountTableViewController

- (void)commonInit{
    [super commonInit];
    
    self.title = [PFUser currentUser].username.uppercaseString;
    
    // setup dismiss button for modal!
    [self setupModalDismissButton];
    
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
            
        case SETTINGS_ROW: {
            cell.textLabel.text = @"Settings";
            
            break;
        }

    }
    
    return cell;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return NUMBER_OF_ROWS;
}

@end
