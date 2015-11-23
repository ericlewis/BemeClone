//
//  InboxTableViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "InboxTableViewController.h"

// HAX FOR LOGOUT
#import "SignupViewController.h"

@interface InboxTableViewController ()

@end

@implementation InboxTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // HAX for when we come from login, since its kind of weird.
    self.navigationItem.hidesBackButton = YES;
    
    // TEMP HAX - set the right bar button item to a logout trigger.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(logoutOfTwitter)];
}

#pragma mark - DGTCompletionViewController

- (void)digitsAuthenticationFinishedWithSession:(DGTSession *)session error:(NSError *)error{
    // we should auth the user here, because that is kind of crappy how Digits works.
}

// HAX
- (void)logoutOfTwitter{
    [[Digits sharedInstance] logOut];
    SignupViewController *signupVC = [SignupViewController new];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setViewControllers:@[signupVC]];
}

@end
