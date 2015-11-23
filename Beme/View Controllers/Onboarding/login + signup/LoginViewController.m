//
//  LoginViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "LoginViewController.h"

#import "UsernameTextField.h"
#import "PhoneNumberTextField.h"

#import "InboxTableViewController.h"

@interface LoginViewController()
@property (nonatomic, strong) UsernameTextField *usernameField;
@property (nonatomic, strong) PhoneNumberTextField *phoneNumberField;

@property (nonatomic, strong) BaseButton *loginButton;
@end

@implementation LoginViewController

- (instancetype)init{
    if (self = [super init]) {
        [self setTitle:@"SIGN IN"];

        // setup dismiss button for modal!
        [self setupModalDismissButton];
        
        // fields
        self.usernameField = [UsernameTextField new];
        self.usernameField.inputAccessoryView = self.loginButton;
        [self.view addSubview:self.usernameField];
        
        self.phoneNumberField = [PhoneNumberTextField new];
        self.phoneNumberField.inputAccessoryView = self.loginButton;
        [self.view addSubview:self.phoneNumberField];
        
        self.loginButton = [BaseButton new];
        [self.loginButton setDefaultTitle:@"SEND CODE"];
        [self.loginButton setTapForTarget:self withSelector:@selector(showVerificationVC)];
        [self.view addSubview:self.loginButton];

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
        
        [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.phoneNumberField.mas_bottom).with.offset(padding);
            make.centerX.equalTo(self.view);
        }];
    }
    
    return self;
}

- (void)showVerificationVC{
    DGTAuthenticationConfiguration *configuration = [[DGTAuthenticationConfiguration alloc] initWithAccountFields:DGTAccountFieldsDefaultOptionMask];
    configuration.phoneNumber = [NSString stringWithFormat:@"+1%@", self.phoneNumberField.text];
    [[Digits sharedInstance] authenticateWithNavigationViewController:self.navigationController configuration:configuration completionViewController:[InboxTableViewController new]];

}

@end
