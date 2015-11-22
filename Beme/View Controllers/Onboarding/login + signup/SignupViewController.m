//
//  SignupViewController.m
//  Beme
//
//  Created by 1debit on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "SignupViewController.h"

#import "BaseNavigationController.h"
#import "LoginViewController.h"
#import "VerifyPhoneViewController.h"

#import "UsernameTextField.h"
#import "PhoneNumberTextField.h"

@interface SignupViewController()
@property (nonatomic, strong) UsernameTextField *usernameField;
@property (nonatomic, strong) PhoneNumberTextField *phoneNumberField;

@property (nonatomic, strong) BaseButton *signupButton;
@property (nonatomic, strong) BaseButton *loginButton;
@end

@implementation SignupViewController

#pragma mark - Setup

- (instancetype)init{
    if (self = [super init]) {
        // fields
        self.usernameField = [UsernameTextField new];
        self.usernameField.inputAccessoryView = self.loginButton;
        [self.view addSubview:self.usernameField];
        
        self.phoneNumberField = [PhoneNumberTextField new];
        self.phoneNumberField.inputAccessoryView = self.loginButton;
        [self.view addSubview:self.phoneNumberField];
        
        // buttons
        self.signupButton = [BaseButton new];
        [self.signupButton setDefaultTitle:@"SIGN UP"];
        [self.signupButton setTapForTarget:self withSelector:@selector(handleSignup)];
        [self.view addSubview:self.signupButton];
        
        self.loginButton = [[BaseButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 45)];
        [self.loginButton setTapForTarget:self withSelector:@selector(showSigninVC)];
        [self.loginButton setDefaultTitle:@"LOG IN"];
        
        // autolayout
        CGFloat padding = 10;
        
        [self.usernameField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
        }];
        
        [self.phoneNumberField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.usernameField.mas_bottom).with.offset(padding);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
        }];
        
        [self.signupButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.phoneNumberField.mas_bottom).with.offset(padding);
            make.centerX.equalTo(self.view);
        }];
        
    }
    
    return self;
}

#pragma mark - FirstResponder

- (BaseButton*)inputAccessoryView{
    return self.loginButton;
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

#pragma mark - Actions

- (void)handleSignup{
    [self showVerificationVC];
}

- (void)showSigninVC{
    LoginViewController *loginVC = [LoginViewController new];
    BaseNavigationController *navVC = [[BaseNavigationController alloc] initWithRootViewController:loginVC];

    [self presentViewController:navVC animated:YES completion:nil];
}

- (void)showVerificationVC{
    VerifyPhoneViewController *verifyVC = [[VerifyPhoneViewController alloc] initWithType:VERIFY_SIGNUP];
    BaseNavigationController *navVC = [[BaseNavigationController alloc] initWithRootViewController:verifyVC];
    
    [self presentViewController:navVC animated:YES completion:nil];
}

@end
