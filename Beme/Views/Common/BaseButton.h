//
//  BaseButton.h
//  Beme
//
//  Created by 1debit on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonViewHeaders.h"

@interface BaseButton : UIButton

- (void)commonInit;

- (void)setDefaultTitle:(NSString *)title;
- (void)setTapForTarget:(id)target withSelector:(SEL)selector;

@end
