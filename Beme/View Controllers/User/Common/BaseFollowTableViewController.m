//
//  BaseFollowTableViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "BaseFollowTableViewController.h"
#import "FindFriendsTableViewController.h"
#import "Constants.h"

#import "Masonry.h"

@interface BaseFollowTableViewController ()
@property (nonatomic, strong) UIButton *emptyButton;
@end

@implementation BaseFollowTableViewController

- (instancetype)init{
    if (self = [super init]) {
        self.parseClassName = kActivityClassKey;
        self.pullToRefreshEnabled = YES;
        self.loadingViewEnabled = YES;
        
        self.emptyButton = [UIButton new];
        [self.emptyButton setTitle:@"Tap here to find people to follow!" forState:UIControlStateNormal];
        [self.emptyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.emptyButton addTarget:self action:@selector(pushFindFriends) forControlEvents:UIControlEventTouchUpInside];
        [self.emptyButton setHidden:YES];
        [self.tableView addSubview:self.emptyButton];
        
        [self.emptyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.tableView);
        }];
    }
    
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[UserFollowCell class] forCellReuseIdentifier:NSStringFromClass([UserFollowCell class])];
}

- (void)pushFindFriends{
    [self.navigationController pushViewController:[FindFriendsTableViewController new] animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.objects.count;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UserFollowCellDelegate

- (void)cell:(UserFollowCell *)cell didTapFollowButton:(PFUser *)user{    
    if (cell.followButton.selected && !self.isLoading) {
        [Utility unfollowUserInBackground:user block:^(BOOL succeeded, NSError *error) {
            if (succeeded && !error) {
                [self loadObjects];
            }else{
                NSLog(@"error: %@", error);
            }
        }];

    }else{
        [Utility followUserInBackground:user block:^(BOOL succeeded, NSError *error) {
            if (succeeded && !error) {
                [self loadObjects];
            }else{
                NSLog(@"error: %@", error);
            }
        }];
    }
}

- (void)objectsDidLoad:(NSError *)error{
    [super objectsDidLoad:error];
    
    if (error || self.objects.count == 0) {
        NSLog(@"show empty.");
        [self.emptyButton setHidden:NO];
    }else{
        // hide empty view;
        [self.emptyButton setHidden:YES];
    }
}

@end
