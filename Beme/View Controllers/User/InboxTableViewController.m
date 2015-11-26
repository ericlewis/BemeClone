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

#import "FontAwesomeKit/FAKIonIcons.h"

@interface InboxTableViewController () <CaptureViewControllerDelegate>
@property (nonatomic, strong) CaptureViewController *captureVC;
@property (nonatomic, strong) UIBarButtonItem *notificationBarButtonItem;
@property (nonatomic, strong) NSArray *myVideosArray;

@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) PFRelation *friendsRelation;

@end

@implementation InboxTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self setupRefreshControl];
    
    // HAX for when we come from login, since its kind of weird.
    self.navigationItem.hidesBackButton = YES;

    // setting icon
    FAKIonIcons *icon = [FAKIonIcons iosGearIconWithSize:25];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[icon imageWithSize:CGSizeMake(25, 25)] style:UIBarButtonItemStylePlain target:self action:@selector(showAccountVC)]];
    
    self.notificationBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"NO REACTIONS" style:UIBarButtonItemStylePlain target:self action:@selector(showReactionsVC)];
    self.notificationBarButtonItem.enabled = NO;
    [self.navigationItem setRightBarButtonItem:self.notificationBarButtonItem];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];    
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
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self retrieveVideos];
    [self loadFriends];

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
    cell.textLabel.text = [videoFile valueForKey:@"senderName"];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"FOLLOWING";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *thing = [self.myVideosArray objectAtIndex:indexPath.row];
    PFFile *file = [thing valueForKey:@"video"];
    
    // show playback
    [self presentViewController:[[PlaybackViewController alloc] initWithVideoURLString:file.url] animated:NO completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.myVideosArray.count;
}

#pragma mark - Actions

- (void)showReactionsVC{

}

- (void)showCaptureVC{
    [self presentViewController:self.captureVC animated:NO completion:nil];
}

- (void)showAccountVC{
    AccountTableViewController *accountVC = [AccountTableViewController new];
    BaseNavigationController *navVC = [[BaseNavigationController alloc] initWithRootViewController:accountVC];
    
    [self presentViewController:navVC animated:YES completion:nil];
}

#pragma mark - Helper methods

- (void)retrieveVideos
{
    PFQuery *recipients = [PFQuery queryWithClassName:@"VideoObject"];
    [recipients whereKey:@"recipientsIds" equalTo:[[PFUser currentUser] objectId]];
    
    PFQuery *senderID = [PFQuery queryWithClassName:@"VideoObject"];
    [senderID whereKey:@"senderId" equalTo:[[PFUser currentUser] objectId]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[recipients, senderID]];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, error.userInfo);
        } else {
        
            self.myVideosArray = objects;
            
            [self.tableView reloadData];
        }
        
        [self.refreshControl endRefreshing];
    }];
}


- (void)loadFriends{
    // add ourself.
    NSMutableArray *mutableFriends = [[NSMutableArray alloc] initWithArray:@[[[PFUser currentUser] objectId]]];
    self.friends = mutableFriends;
    
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];
    
    PFQuery *query = [self.friendsRelation query];
    [query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, error.userInfo);
        } else {
            for (PFUser *friend in friends) {
                [mutableFriends addObject:friend.objectId];
            }
            
            self.friends = mutableFriends;
        }
    }];
}

#pragma mark - DGTCompletionViewController

- (void)digitsAuthenticationFinishedWithSession:(DGTSession *)session error:(NSError *)error{
    // we should auth the user here, because that is kind of crappy how Digits works.
}

#pragma mark - CaptureViewControllerDelegate

- (void)tookVideo:(NSURL*)outputURL withFilename:(NSString*)name{
    NSData *imageData = [NSData dataWithContentsOfURL:outputURL];
    PFFile *videofile = [PFFile fileWithName:name data:imageData];

    UIView *uploadHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 50)];
    UIActivityIndicatorView *activitiyIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [uploadHeader addSubview:activitiyIndicatorView];
    [activitiyIndicatorView setCenter:uploadHeader.center];
    [activitiyIndicatorView startAnimating];
    
    self.tableView.tableHeaderView = uploadHeader;

    [videofile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded && !error) {
            
            // video object
            PFObject *videoObject = [PFObject objectWithClassName:@"VideoObject"];
            
            // these are who can see it.
            [videoObject setObject:self.friends forKey:@"recipientsIds"];
            
            // these are who have seen it
            [videoObject setObject:self.friends forKey:@"recipientsUnreadIds"];
            
            // our beautiful ID
            [videoObject setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
            
            // our pretty name
            [videoObject setObject:[[PFUser currentUser] username] forKey:@"senderName"];
        
            // this is the actual video...
            [videoObject setObject:videofile forKey:@"video"];

            [videoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                    } else{
                    // Error
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
            }];
        }
        
    } progressBlock:^(int percentDone) {
        NSLog(@"vid upload percent: %i", percentDone);
        
        if (percentDone == 100) {
            self.tableView.tableHeaderView = nil;
            [self performSelector:@selector(refreshData) withObject:nil afterDelay:1];
        }
        
    }];
}

- (void)refreshData{
    [self retrieveVideos];
}

@end
