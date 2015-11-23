//
//  InboxTableViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "InboxTableViewController.h"
#import <Parse/Parse.h>

#import "BaseNavigationController.h"
#import "AccountTableViewController.h"
#import "CaptureViewController.h"

#import "FontAwesomeKit/FAKIonIcons.h"

// HAX FOR LOGOUT
#import "SignupViewController.h"

@interface InboxTableViewController ()
@property (nonatomic, strong) CaptureViewController *captureVC;
@property (nonatomic, strong) UIBarButtonItem *notificationBarButtonItem;

@end

@implementation InboxTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.captureVC = [CaptureViewController new];
    
    // HAX for when we come from login, since its kind of weird.
    self.navigationItem.hidesBackButton = YES;

    // setting icon
    FAKIonIcons *icon = [FAKIonIcons iosGearIconWithSize:25];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[icon imageWithSize:CGSizeMake(25, 25)] style:UIBarButtonItemStylePlain target:self action:@selector(showAccountVC)]];
    
    self.notificationBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"NO REACTIONS" style:UIBarButtonItemStylePlain target:self action:@selector(showReactionsVC)];
    self.notificationBarButtonItem.enabled = NO;
    [self.navigationItem setRightBarButtonItem:self.notificationBarButtonItem];
    
    // Enabled monitoring of the sensor
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
}

#pragma mark - Lifecycle

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
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

#pragma mark - DGTCompletionViewController

- (void)digitsAuthenticationFinishedWithSession:(DGTSession *)session error:(NSError *)error{
    // we should auth the user here, because that is kind of crappy how Digits works.
}

// HAX
- (void)logoutOfTwitter{
    [PFUser logOut];
    SignupViewController *signupVC = [SignupViewController new];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setViewControllers:@[signupVC]];
}

@end
