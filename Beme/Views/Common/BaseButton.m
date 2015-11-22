//
//  BaseButton.m
//  Beme
//
//  Created by 1debit on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "BaseButton.h"

@implementation BaseButton

- (instancetype)init{
    if (self = [super init]) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit{
    [self setTitleColor:[UIColor commonForegroundColor] forState:UIControlStateNormal];
}

- (void)setDefaultTitle:(NSString *)title{
    [self setTitle:title forState:UIControlStateNormal];
}

- (void)setTapForTarget:(id)target withSelector:(SEL)selector{
    [self addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

@end
