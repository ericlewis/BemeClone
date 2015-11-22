//
//  NSUserDefaults+Additions.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "NSUserDefaults+Additions.h"

static NSString *WAS_SIGNUP_SHOWN_KEY = @"WAS_SIGNUP_SHOWN_KEY";

@implementation NSUserDefaults (Additions)

- (void)markSignupShown{
    [self setValue:@(YES) forKey:WAS_SIGNUP_SHOWN_KEY];
}

- (BOOL)wasSignupShown{
    return [self valueForKey:WAS_SIGNUP_SHOWN_KEY];
}

@end