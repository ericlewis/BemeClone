//
//  Cache.m
//  Beme
//
//  Created by Eric Lewis on 11/25/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "Cache.h"
#import "Constants.h"

@interface Cache()
@property (nonatomic, strong) NSCache *cache;
@end

@implementation Cache

+ (id)sharedCache{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init{
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - Cache

- (void)clear{
    [self.cache removeAllObjects];
}

- (BOOL)followStatusForUser:(PFUser *)user{
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *followStatus = [attributes objectForKey:kUserAttributesIsFollowedByCurrentUserKey];
        if (followStatus) {
            return [followStatus boolValue];
        }
    }
    
    return NO;
}

- (void)setFollowStatus:(BOOL)following user:(PFUser *)user{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:[NSNumber numberWithBool:following] forKey:kUserAttributesIsFollowedByCurrentUserKey];
    [self setAttributes:attributes forUser:user];
}

- (NSDictionary *)attributesForUser:(PFUser *)user{
    NSString *key = [self keyForUser:user];
    return [self.cache objectForKey:key];
}

#pragma mark - Helpers

- (void)setAttributes:(NSDictionary *)attributes forUser:(PFUser *)user{
    NSString *key = [self keyForUser:user];
    [self.cache setObject:attributes forKey:key];
}

- (NSString *)keyForUser:(PFUser *)user{
    return [NSString stringWithFormat:@"user_%@", [user objectId]];
}

@end
