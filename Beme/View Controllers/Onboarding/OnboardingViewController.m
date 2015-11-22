//
//  OnboardingViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "OnboardingViewController.h"

#import "BaseNavigationController.h"
#import "SignupViewController.h"

@interface OnboardingViewController()
@property (nonatomic, strong) BaseButton *gettingStartedButton;
@end

@implementation OnboardingViewController

- (instancetype)init{
    if (self = [super init]) {
        self.gettingStartedButton = [BaseButton new];
        [self.gettingStartedButton setDefaultTitle:@"GET STARTED"];
        [self.gettingStartedButton setTapForTarget:self withSelector:@selector(showSignupVC)];
        
        [self.view addSubview:self.gettingStartedButton];
        
        [self.gettingStartedButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
        }];
    }
    
    return self;
}

#pragma mark - Actions

- (void)showSignupVC{
    // record the fact that we pressed the button so next time its launched we will properly display the signup VC
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
    
    [UIView transitionWithView:window
                      duration:0.34
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        SignupViewController *signupVC = [SignupViewController new];
                        BaseNavigationController *navVC = [[BaseNavigationController alloc] initWithRootViewController:signupVC];
                        [navVC setNavigationBarHidden:YES];
                        [window setRootViewController:navVC];
                    }
                    completion:nil];
}

@end
