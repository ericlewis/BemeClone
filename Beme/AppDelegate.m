//
//  AppDelegate.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <DigitsKit/DigitsKit.h>

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
    [Fabric with:@[[Crashlytics class], [Digits class]]];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    if ([PFUser currentUser] || [[Digits sharedInstance] session]) {
        InboxTableViewController *inboxVC = [InboxTableViewController new];
        BaseNavigationController *navVC = [[BaseNavigationController alloc] initWithRootViewController:inboxVC];
        [self.window setRootViewController:navVC];
        
        [[Digits sharedInstance] logOut];
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
