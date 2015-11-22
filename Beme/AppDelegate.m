//
//  AppDelegate.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "AppDelegate.h"

// network
#import <Parse/Parse.h>

// utilities
#import "NSUserDefaults+Additions.h"

// VCs
#import "BaseNavigationController.h"
#import "InboxTableViewController.h"
#import "OnboardingViewController.h"
#import "SignupViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    if ([PFUser currentUser]) {
        InboxTableViewController *inboxVC = [InboxTableViewController new];
        BaseNavigationController *navVC = [[BaseNavigationController alloc] initWithRootViewController:inboxVC];
        [self.window setRootViewController:navVC];
        
    }else if ([[NSUserDefaults standardUserDefaults] wasSignupShown]) {
        SignupViewController *signupVC = [SignupViewController new];
        BaseNavigationController *navVC = [[BaseNavigationController alloc] initWithRootViewController:signupVC];
        [navVC setNavigationBarHidden:YES];
        [self.window setRootViewController:navVC];
        
    }else{
        self.window.rootViewController = [OnboardingViewController new];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
