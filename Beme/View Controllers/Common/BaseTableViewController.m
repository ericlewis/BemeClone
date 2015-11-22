//
//  BaseTableViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "BaseTableViewController.h"

@implementation BaseTableViewController

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
    [self.tableView setBackgroundColor:[UIColor commonBackgroundColor]];
}

@end
