//
//  VerifyPhoneViewController.h
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, VerificationType) {
    VERIFY_SIGNUP,
    VERIFY_LOGIN,
};

@interface VerifyPhoneViewController : BaseViewController

- (instancetype)initWithType:(VerificationType)verifyType;

@end
