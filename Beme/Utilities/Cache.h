//
//  Cache.h
//  Beme
//
//  Created by Eric Lewis on 11/25/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

#import "Constants.h"

@interface Cache : NSObject

+ (id)sharedCache;

- (void)clear;
- (BOOL)followStatusForUser:(PFUser *)user;
- (void)setFollowStatus:(BOOL)following user:(PFUser *)user;
- (NSDictionary *)attributesForUser:(PFUser *)user;

@end
