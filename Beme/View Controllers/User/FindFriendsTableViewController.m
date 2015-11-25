//
//  FindFriendsTableViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "FindFriendsTableViewController.h"

#import <Parse/Parse.h>

@interface FindFriendsTableViewController ()
@property (nonatomic, strong) NSArray *allUsers;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) PFRelation *friendsRelation;
@end

@implementation FindFriendsTableViewController

- (void)commonInit{
    [super commonInit];
    
    self.title = @"FIND FRIENDS";
}

#pragma mark - Lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self loadFriends];
    [self loadEveryone];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
    
    cell.textLabel.text = user.username;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
    
    if ([self isFriend:user]) {
        [self.friendsRelation removeObject:user];
        NSLog(@"friend!");
    }else{
        [self.friendsRelation addObject:user];
        NSLog(@"not friend!");
    }
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, error.userInfo);
        }
        
        [self loadFriends];
        [self loadEveryone];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allUsers.count;
}

#pragma mark - Helpers

- (BOOL)isFriend:(PFUser *)user{
    for (PFUser *friend in self.friends) {
        if ([friend.objectId isEqualToString:user.objectId]) {
            return YES;
        }
    }
    return NO;
}

- (void)loadEveryone{
    PFQuery *query = [PFUser query];
    [query orderByAscending:@"username"];
    [query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error){
            NSLog(@"Error: %@ %@", error, error.userInfo);
        } else {
            self.allUsers = objects;
            [self.tableView reloadData];
        }
    }];
}

- (void)loadFriends{
    PFQuery *query = [self.friendsRelation query];
    [query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, error.userInfo);
        } else {
            self.friends = objects;
            NSLog(@"%@", self.friends);
            [self.tableView reloadData];
        }
    }];
}

@end
