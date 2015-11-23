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
@property (nonatomic, strong) NSTimer *finishTimer;
@property (nonatomic, strong) BaseLabel *captureStatusLabel;
@end

@implementation CaptureViewController

- (void)commonInit{
    [super commonInit];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // for some reason, reusing this is not a great idea?
    if (!self.captureStatusLabel) {
        self.captureStatusLabel = [BaseLabel new];
        self.captureStatusLabel.textColor = [UIColor redColor];
        self.captureStatusLabel.text = @"RECORDING";
        [self.view addSubview:self.captureStatusLabel];
        
        [self.captureStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.right.left.equalTo(self.view);
        }];
    }
}

#pragma mark - Prox Sensor

- (void)sensorStateChange:(NSNotificationCenter *)notification
{
    if ([[UIDevice currentDevice] proximityState] == NO){
        if (self.finishTimer.isValid) {
            // set the capture status to cancelled since they decided not to wait long enough
            self.captureStatusLabel.text = @"CANCELLED";
            self.captureStatusLabel.textColor = [UIColor whiteColor];
        }else{
            // reset for record mode since we recycle the view
            self.captureStatusLabel.text = @"";
            self.captureStatusLabel.textColor = [UIColor redColor];
        }
        
        // fuck the timer though
        [self.finishTimer invalidate];
        
        [self performSelector:@selector(dismissView) withObject:nil afterDelay:0.57];

    }else{
        self.captureStatusLabel.textColor = [UIColor redColor];
        self.captureStatusLabel.text = @"RECORDING";
    }
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // mmm vibrations, sound coming soon?
    [self vibrate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)
                                                 name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // schedule a timer yo.
    self.finishTimer = [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(vibrate) userInfo:nil repeats:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.finishTimer invalidate];
    [self.captureStatusLabel setText:@"RECORDING"];
    self.captureStatusLabel.textColor = [UIColor redColor];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

- (void)dismissView{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)vibrate{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

@end
