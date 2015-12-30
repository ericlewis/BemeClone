//
//  InboxTableViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "InboxTableViewController.h"
#import <Parse/Parse.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "BaseNavigationController.h"
#import "AccountTableViewController.h"
#import "CaptureViewController.h"
#import "PlaybackViewController.h"
#import "ReactionViewController.h"
#import "FindFriendsTableViewController.h"

#import "Constants.h"

@interface InboxTableViewController () <CaptureViewControllerDelegate>
@property (nonatomic, strong) CaptureViewController *captureVC;
@property (nonatomic, strong) UIBarButtonItem *notificationBarButtonItem;
@property (nonatomic, strong) UIButton *emptyButton;
@property (nonatomic, strong) NSArray *myVideosArray;
@property (nonatomic, strong) NSArray *myReactionsArray;
@property (nonatomic, strong) NSMutableArray *friends;

@property (nonatomic, assign) UIBackgroundTaskIdentifier videoPostBackgroundTaskId;

@end

@implementation InboxTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self setupRefreshControl];
    
    // HAX for when we come from login, since its kind of weird.
    self.navigationItem.hidesBackButton = YES;

    // user account
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:[PFUser currentUser].username style:UIBarButtonItemStylePlain target:self action:@selector(showAccountVC)]];
    
    self.notificationBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"NO REACTIONS" style:UIBarButtonItemStylePlain target:self action:@selector(showReactionsVC)];
    self.notificationBarButtonItem.enabled = NO;
    [self.navigationItem setRightBarButtonItem:self.notificationBarButtonItem];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    
    // empty view
    self.emptyButton = [UIButton new];
    [self.emptyButton setTitle:@"Tap here to find people to follow!" forState:UIControlStateNormal];
    [self.emptyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.emptyButton addTarget:self action:@selector(showFindFriends) forControlEvents:UIControlEventTouchUpInside];
    [self.emptyButton setHidden:YES];
    [self.tableView addSubview:self.emptyButton];
    
    [self.emptyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.tableView);
    }];
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        // Enabled monitoring of the sensor
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        
        if (!self.captureVC) {
            self.captureVC = [CaptureViewController new];
            self.captureVC.secondaryDelegate = self;
        }
    }
    
    [self loadFriends];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self refreshData];
    
    // Set up an observer for proximity changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)
                                                 name:@"UIDeviceProximityStateDidChangeNotification" object:nil];    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Prox Sensor

- (void)sensorStateChange:(NSNotificationCenter *)notification
{
    if ([[UIDevice currentDevice] proximityState] == YES){
        [self showCaptureVC];
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];

    NSDictionary *videoFile = [self.myVideosArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %lu", [videoFile valueForKey:@"username"], [[videoFile valueForKey:@"videos"] count]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"FOLLOWING";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *thing = [self.myVideosArray objectAtIndex:indexPath.row];
    
    // show playback
    [self presentViewController:[[PlaybackViewController alloc] initWithVideoArray:[thing valueForKey:@"videos"] fromUser:[thing valueForKey:@"userID"]] animated:NO completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.myVideosArray.count;
}

#pragma mark - Actions

- (void)showReactionsVC{
    [self presentViewController:[[ReactionViewController alloc] initWithReactionArray:self.myReactionsArray] animated:NO completion:nil];
}

- (void)showCaptureVC{
    [self presentViewController:self.captureVC animated:NO completion:nil];
}

- (void)showAccountVC{
    AccountTableViewController *accountVC = [AccountTableViewController new];
    BaseNavigationController *navVC = [[BaseNavigationController alloc] initWithRootViewController:accountVC];
    
    [self presentViewController:navVC animated:YES completion:nil];
}

- (void)showFindFriends{
    AccountTableViewController *accountVC = [AccountTableViewController new];
    BaseNavigationController *navVC = [[BaseNavigationController alloc] initWithRootViewController:accountVC];
    [navVC pushViewController:[FindFriendsTableViewController new] animated:NO];
    
    [self presentViewController:navVC animated:YES completion:nil];
}

#pragma mark - Helper methods

- (void)retrieveVideos
{
    // retrieve all the videos for the people we follow.
    
    // this may be some sort of weird union, because the old method is certainly way easier.
    
    // also, maybe just use the old method. it seriously is way easier.
    
    // if anyone wants to FIXME, that would be cool. but idk.
    
    // get all our followers videos
    PFQuery *query = [PFQuery queryWithClassName:kVideoClassKey];
    [query whereKey:kVideoRecipientsUnreadIdsKey equalTo:[[PFUser currentUser] objectId]];

    [query orderByDescending:@"createdAt"];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, error.userInfo);
        } else {
            
            NSMutableArray *videos = [NSMutableArray new];
            
            // loop the video objects
            for(PFObject *video in objects) {
                
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"senderId == %@", [video valueForKey:kVideoSenderIdKey]];
                NSArray *filteredArr = [objects filteredArrayUsingPredicate:pred];
                
                // extract the sendername / ID - we use this to make sure it is unique.
                NSDictionary *userObject = @{
                                             @"username"    : [video valueForKey:kVideoSenderNameKey],
                                             @"userID"      : [video valueForKey:kVideoSenderIdKey],
                                             @"videos"      : filteredArr
                                             };
                
                if (![videos containsObject:userObject]) {
                    [videos addObject:@{
                                       @"username"    : [video valueForKey:kVideoSenderNameKey],
                                       @"userID"      : [video valueForKey:kVideoSenderIdKey],
                                       @"videos"      : filteredArr
                                       }];
                }
            }
            
            self.myVideosArray = videos;
            
            if (self.myVideosArray.count == 0) {
                // show empty view
                [self.emptyButton setHidden:NO];
            }else{
                // dont?
                [self.emptyButton setHidden:YES];
            }
            
            [self.tableView reloadData];
        }
        
        [self.refreshControl endRefreshing];
    }];
}

- (void)retrieveReactions{
    PFQuery *query = [PFQuery queryWithClassName:kReactionClassKey];
    [query whereKey:kReactionRecipientsUnreadIdKey equalTo:[[PFUser currentUser] objectId]];
    
    [query orderByDescending:@"createdAt"];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.notificationBarButtonItem setEnabled:YES];
        
        self.myReactionsArray = objects;
        
        // no reactions
        if (objects.count == 0) {
            [self.notificationBarButtonItem setTitle:@"NO REACTIONS"];
            [self.notificationBarButtonItem setEnabled:NO];

        }else if(objects.count == 1){
            [self.notificationBarButtonItem setTitle:@"1 REACTION"];
        }else{
            [self.notificationBarButtonItem setTitle:[NSString stringWithFormat:@"%lu REACTIONS", (unsigned long)objects.count]];
        }
    }];
}

- (void)loadFriends{
    if ([PFUser currentUser]) {
        NSMutableArray *mutableFriends = [[NSMutableArray alloc] initWithArray:@[[[PFUser currentUser] objectId]]];
        
        PFQuery *query = [PFQuery queryWithClassName:kActivityClassKey];
        [query whereKey:kActivityTypeKey equalTo:kActivityTypeFollow];
        [query whereKey:kActivityFromUserKey equalTo:[PFUser currentUser]];
        [query selectKeys:@[kActivityToUserKey]];
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
            if (error) {
                NSLog(@"Error: %@ %@", error, error.userInfo);
            } else {
                for (PFUser *friend in friends) {
                    NSString *objectIdForFriend = [[friend valueForKey:kActivityToUserKey] valueForKey:@"objectId"];
                    if (![mutableFriends containsObject:objectIdForFriend]) {
                        [mutableFriends addObject:objectIdForFriend];
                    }
                }
                
                self.friends = mutableFriends;
            }
        }];
    }
}


#pragma mark - DGTCompletionViewController

- (void)digitsAuthenticationFinishedWithSession:(DGTSession *)session error:(NSError *)error{
    // we should auth the user here, because that is kind of crappy how Digits works.
}

#pragma mark - CaptureViewControllerDelegate

- (void)tookVideo:(NSURL*)outputURL withFilename:(NSString*)name{
    UIView *uploadHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 50)];
    UIActivityIndicatorView *activitiyIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [uploadHeader addSubview:activitiyIndicatorView];
    [activitiyIndicatorView setCenter:uploadHeader.center];
    [activitiyIndicatorView startAnimating];
    
    self.tableView.tableHeaderView = uploadHeader;
    
    NSData *videoData = [NSData dataWithContentsOfURL:outputURL];
    PFFile *videofile = [PFFile fileWithName:name data:videoData];
    
    // create a video object
    PFObject *video = [PFObject objectWithClassName:kVideoClassKey];
    [video setObject:[PFUser currentUser] forKey:kVideoUserKey];
    [video setObject:videofile forKey:kVideoFileKey];
    [video setObject:@(4) forKey:kVideoLengthKey];
    [video setObject:self.friends forKey:kVideoRecipientsIdsKey];
    [video setObject:self.friends forKey:kVideoRecipientsUnreadIdsKey];
    [video setObject:[PFUser currentUser].objectId forKey:kVideoSenderIdKey];
    [video setObject:[PFUser currentUser].username forKey:kVideoSenderNameKey];

    // Request a background execution task to allow us to finish uploading the video even if the app is backgrounded
    self.videoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.videoPostBackgroundTaskId];
    }];

    [video saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error){
        if (error) {
            NSLog(@"%@", error);
        }
        
        [[UIApplication sharedApplication] endBackgroundTask:self.videoPostBackgroundTaskId];
        
        self.tableView.tableHeaderView = nil;
        [self performSelector:@selector(refreshData) withObject:nil afterDelay:.25];
    }];
}

- (void)refreshData{
    if ([PFUser currentUser]) {
        [self retrieveVideos];
        [self retrieveReactions];
    }
}

@end
