//
//  Constants.m
//  Beme
//
//  Created by Eric Lewis on 11/25/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "Constants.h"

#pragma mark - Activity Class
// Class key
NSString *const kActivityClassKey = @"Activity";

// Field keys
NSString *const kActivityTypeKey        = @"type";
NSString *const kActivityFromUserKey    = @"fromUser";
NSString *const kActivityToUserKey      = @"toUser";
NSString *const kActivityContentKey     = @"content";
NSString *const kActivityVideoKey       = @"video";

// Type values
NSString *const kActivityTypeFollow     = @"follow";
NSString *const kActivityTypeReaction   = @"reaction";
NSString *const kActivityTypeJoined     = @"joined";
