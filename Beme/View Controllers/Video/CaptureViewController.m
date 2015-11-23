//
//  CaptureViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "CaptureViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface CaptureViewController ()

@end

@implementation CaptureViewController

- (void)commonInit{
    [super commonInit];
    
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLoad{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)
                                                 name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

#pragma mark - Prox Sensor

- (void)sensorStateChange:(NSNotificationCenter *)notification
{
    if ([[UIDevice currentDevice] proximityState] == NO){
        [self performSelector:@selector(dismissView) withObject:nil afterDelay:0.2];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

#pragma mark - Actions

- (void)dismissView{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
