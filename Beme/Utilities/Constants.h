//
//  Constants.h
//  Beme
//
//  Created by Eric Lewis on 11/25/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Activity Class

// Class key
extern NSString *const kActivityClassKey;

// Field keys
extern NSString *const kActivityTypeKey;
extern NSString *const kActivityFromUserKey;
extern NSString *const kActivityToUserKey;
extern NSString *const kActivityContentKey;
extern NSString *const kActivityVideoKey;

// Type values
extern NSString *const kActivityTypeFollow;
extern NSString *const kActivityTypeReaction;
extern NSString *const kActivityTypeWatched;
extern NSString *const kActivityTypeJoined;

#pragma mark - Video Class

// Class key
extern NSString *const kVideoClassKey;

// Field keys
extern NSString *const kVideoFileKey;
extern NSString *const kVideoUserKey;

#pragma mark - Cached User Attributes

// Keys
extern NSString *const kUserAttributesIsFollowedByCurrentUserKey;