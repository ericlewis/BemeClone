//
//  UIViewController+Additions.m
//  Beme
//
//  Created by 1debit on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "UIViewController+Additions.h"

@implementation UIViewController (Additions)

- (void)setupBlankBackButton{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
}

- (void)setupModalDismissButton{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissViewController)];
}

- (void)dismissViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
