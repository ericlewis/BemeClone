//
//  SignupViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "SignupViewController.h"
#import "NSUserDefaults+Additions.h"

#import "BaseNavigationController.h"
#import "LoginViewController.h"
#import "InboxTableViewController.h"

#import "UsernameTextField.h"
#import "PhoneNumberTextField.h"

@interface SignupViewController() <UITextFieldDelegate>
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
        self.usernameField.delegate = self;
        self.usernameField.inputAccessoryView = self.loginButton;
        
        if ([[NSUserDefaults standardUserDefaults] preferredUsername].chuzzle) {
            self.usernameField.text = [[NSUserDefaults standardUserDefaults] preferredUsername];
        }
        
        [self.view addSubview:self.usernameField];
        
        self.phoneNumberField = [PhoneNumberTextField new];
        self.phoneNumberField.inputAccessoryView = self.loginButton;
        self.phoneNumberField.delegate = self;
        [self.view addSubview:self.phoneNumberField];
        
        // buttons
        self.signupButton = [BaseButton new];
        [self.signupButton setDefaultTitle:@"SIGN UP"];
        [self.signupButton setTapForTarget:self withSelector:@selector(handleSignup)];
        [self.signupButton setEnabled:NO];
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
    [self showVerificationModalVC];
}

- (void)showVerificationModalVC{
    [[NSUserDefaults standardUserDefaults] recordPreferredUsername:self.usernameField.text];
    
    Digits *digits = [Digits sharedInstance];
    DGTAuthenticationConfiguration *configuration = [[DGTAuthenticationConfiguration alloc] initWithAccountFields:DGTAccountFieldsDefaultOptionMask];
    configuration.phoneNumber = [NSString stringWithFormat:@"+1%@", self.phoneNumberField.text];
    [digits authenticateWithViewController:nil configuration:configuration completion:^(DGTSession *newSession, NSError *error){
        if (error) {
            NSLog(@"%@", error);
        }else if (newSession.phoneNumber) {
            [self showInboxVC];
        }
    }];
}

- (void)showInboxVC{
    InboxTableViewController *inboxVC = [InboxTableViewController new];
    [(BaseNavigationController*)self.parentViewController setNavigationBarHidden:NO];
    [(BaseNavigationController*)self.parentViewController setViewControllers:@[inboxVC]];
}

- (void)showSigninVC{
    LoginViewController *loginVC = [LoginViewController new];
    BaseNavigationController *navVC = [[BaseNavigationController alloc] initWithRootViewController:loginVC];

    [self presentViewController:navVC animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

// TODO IMPROVE
// just dont allow blank stuff for now.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (self.usernameField.text.chuzzle && self.phoneNumberField.text.chuzzle) {
        [self.signupButton setEnabled:YES];
    }else{
        [self.signupButton setEnabled:NO];
    }
        
    return YES;
}

@end
