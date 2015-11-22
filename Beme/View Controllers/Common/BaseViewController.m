//
//  BaseViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "BaseViewController.h"

@implementation BaseViewController

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

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit{
    [self setupBlankBackButton];
    [self.view setBackgroundColor:[UIColor commonBackgroundColor]];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
}

@end
