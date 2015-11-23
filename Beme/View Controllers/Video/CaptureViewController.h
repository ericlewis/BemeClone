//
//  CaptureViewController.h
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "BaseViewController.h"

@protocol CaptureViewControllerDelegate <NSObject>
- (void)tookVideo:(NSURL*)outputURL withFilename:(NSString*)name;
@end

@interface CaptureViewController : UIImagePickerController
@property (nonatomic, weak) id<CaptureViewControllerDelegate> secondaryDelegate;
@end
