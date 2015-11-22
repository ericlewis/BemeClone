//
//  VerifyPhoneViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "VerifyPhoneViewController.h"

#import "InboxTableViewController.h"
#import "BaseNavigationController.h"

#import "VerificationTextField.h"

@interface VerifyPhoneViewController()
@property (nonatomic, strong) VerificationTextField *verificationField;
@property (nonatomic, strong) BaseButton *verifyButton;
@property (nonatomic) VerificationType verifyType;
@end

@implementation VerifyPhoneViewController

- (instancetype)initWithType:(VerificationType)verifyType{
    if (self = [super init]) {
        
        self.verifyType = verifyType;
        
        [self setTitle:@"VERIFY"];
        
        // setup dismiss button for modal!
        if (verifyType == VERIFY_SIGNUP) {
            [self setupModalDismissButton];
        }
        
        // fields
        self.verificationField = [VerificationTextField new];
        [self.view addSubview:self.verificationField];
        
        // buttons
        self.verifyButton = [BaseButton new];
        [self.verifyButton setDefaultTitle:@"VERIFY"];
        [self.verifyButton setTapForTarget:self withSelector:@selector(handleVerification)];
        [self.view addSubview:self.verifyButton];
        
        // autolayout
        CGFloat padding = 10;
        
        [self.verificationField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
        }];
        
        [self.verifyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.verificationField.mas_bottom).with.offset(padding);
            make.centerX.equalTo(self.view);
        }];
    }
    
    return self;
}

#pragma mark - Actions

- (void)handleVerification{

    if (self.verifyType == VERIFY_SIGNUP) {
        NSLog(@"signup.");
        [self showInboxVC];
        
    }else if(self.verifyType == VERIFY_LOGIN){
        NSLog(@"login.");
        [self showInboxVC];

    }else{
        NSLog(@"no type.");
    }
    
}

- (void)showInboxVC{
    UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
    
    [UIView transitionWithView:window
                      duration:0.34
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        InboxTableViewController *inboxVC = [InboxTableViewController new];
                        BaseNavigationController *navVC = [[BaseNavigationController alloc] initWithRootViewController:inboxVC];
                        [window setRootViewController:navVC];
                    }
                    completion:nil];
}

@end
