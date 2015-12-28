//
//  PlaybackViewController.h
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "BaseViewController.h"

@interface PlaybackViewController : BaseViewController

- (instancetype)initWithVideoArray:(NSArray*)videos fromUser:(NSString*)userID;

@end
