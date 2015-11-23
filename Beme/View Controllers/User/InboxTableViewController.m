//
//  InboxTableViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "InboxTableViewController.h"
#import <Parse/Parse.h>

#import "CaptureViewController.h"

// HAX FOR LOGOUT
#import "SignupViewController.h"

@interface InboxTableViewController ()
@property (nonatomic, strong) CaptureViewController *captureVC;
@end

@implementation InboxTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.captureVC = [CaptureViewController new];
    
    // HAX for when we come from login, since its kind of weird.
    self.navigationItem.hidesBackButton = YES;
    
    // TEMP HAX - set the right bar button item to a logout trigger.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(logoutOfTwitter)];
    
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

- (void)showCaptureVC{
    [self presentViewController:self.captureVC animated:NO completion:nil];
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
