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
extern NSString *const kVideoLengthKey;
extern NSString *const kVideoRecipientsIdsKey;
extern NSString *const kVideoRecipientsUnreadIdsKey;
extern NSString *const kVideoSenderIdKey;
extern NSString *const kVideoSenderNameKey;
extern NSString *const kVideoUserKey;

#pragma mark - Reaction Class

// Class key
extern NSString *const kReactionClassKey;

// Field keys
extern NSString *const kReactionFileKey;
extern NSString *const kReactionRecipientsIdKey;
extern NSString *const kReactionRecipientsUnreadIdKey;
extern NSString *const kReactionSenderIdKey;
extern NSString *const kReactionSenderNameKey;
extern NSString *const kReactionUserKey;

#pragma mark - Cached User Attributes

// Keys
extern NSString *const kUserAttributesIsFollowedByCurrentUserKey;