//
//  AppDelegate.m
//  Beme
//
//  Created by 1debit on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "AppDelegate.h"

#import "OnboardingViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [OnboardingViewController new];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
