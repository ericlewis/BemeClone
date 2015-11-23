//
//  NSUserDefaults+Additions.h
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Additions)

- (void)markSignupShown;
- (BOOL)wasSignupShown;

- (void)recordPreferredUsername:(NSString*)username;
- (NSString*)preferredUsername;

@end
