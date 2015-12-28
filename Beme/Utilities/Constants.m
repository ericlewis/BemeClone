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
NSString *const kActivityTypeWatched    = @"watched";
NSString *const kActivityTypeJoined     = @"joined";


#pragma mark - Video Class

// Class key
NSString *const kVideoClassKey = @"Video";

// Field keys
NSString *const kVideoFileKey                = @"video";
NSString *const kVideoLengthKey              = @"length";
NSString *const kVideoRecipientsIdsKey       = @"recipientsIds";
NSString *const kVideoRecipientsUnreadIdsKey = @"recipientsUnreadIds";
NSString *const kVideoSenderIdKey            = @"senderId";
NSString *const kVideoSenderNameKey          = @"senderName";
NSString *const kVideoUserKey                = @"user";

#pragma mark - Reaction Class

// Class key
NSString *const kReactionClassKey = @"Reaction";

// Field keys
NSString *const kReactionFileKey               = @"photo";
NSString *const kReactionRecipientsIdKey       = @"recipientsId";
NSString *const kReactionRecipientsUnreadIdKey = @"recipientsUnreadId";
NSString *const kReactionSenderIdKey           = @"senderId";
NSString *const kReactionSenderNameKey         = @"senderName";
NSString *const kReactionUserKey               = @"user";

#pragma mark - Cached User Attributes

// keys
NSString *const kUserAttributesIsFollowedByCurrentUserKey = @"isFollowedByCurrentUser";
