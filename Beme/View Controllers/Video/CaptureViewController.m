//
//  CaptureViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "CaptureViewController.h"

// for playing vibration
#import <AudioToolbox/AudioToolbox.h>

// for saving the data locally
#import <MobileCoreServices/MobileCoreServices.h>

// for saving remotely
#import <Parse/Parse.h>

@interface CaptureViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) NSTimer *finishTimer;
@property (nonatomic, strong) NSTimer *videoRecordTimer;
@property (nonatomic, strong) BaseLabel *captureStatusLabel;
@property (nonatomic) BOOL videoIsLongEnough;
@end

@implementation CaptureViewController

- (instancetype)init{
    if (self = [super init]) {
        self.view.backgroundColor = [UIColor blackColor];
        self.delegate = self;
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.showsCameraControls = NO;
        self.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        self.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        self.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        
        // this is lame :(
        //self.videoMaximumDuration = 7;

        // for some reason, reusing this is not a great idea?
        if (!self.captureStatusLabel) {
            UIView *background = [[UIView alloc] initWithFrame:self.view.frame];
            [background setBackgroundColor:[UIColor commonForegroundColor]];
            [self.view addSubview:background];

            self.captureStatusLabel = [BaseLabel new];
            self.captureStatusLabel.textColor = [UIColor redColor];
            self.captureStatusLabel.text = @"RECORDING";
            [background addSubview:self.captureStatusLabel];
            
            [self.captureStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_topLayoutGuideBottom);
                make.right.left.equalTo(background);
            }];
        }
    }
    
    return self;
}

#pragma mark - Prox Sensor

- (void)sensorStateChange:(NSNotificationCenter *)notification
{
    // device is no longer held close.
    if ([[UIDevice currentDevice] proximityState] == NO){
        
        // stop the video capture now.
        [self stopVideoCapture];
        [self.finishTimer invalidate];
        [self.videoRecordTimer invalidate];
        
        // if the video isn't long enough, say cancelled. if it is, just blank it out.
        if (!self.videoIsLongEnough) {
            // set the capture status to cancelled since they decided not to wait long enough
            self.captureStatusLabel.text = @"CANCELLED";
            self.captureStatusLabel.textColor = [UIColor whiteColor];
            
            [self performSelector:@selector(dismissVC) withObject:nil afterDelay:0.4];
        }else{
            // reset for record mode since we recycle the view
            self.captureStatusLabel.text = @"";
            self.captureStatusLabel.textColor = [UIColor redColor];
        }
        
    }
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // vibrate to indicate recording has started
    [self vibrate];
    
    // listen for sensor changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)
                                                 name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // schedule a timer to keep tracking of video length
    self.videoIsLongEnough = NO;
    self.videoRecordTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startCameraCapture) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // kill the timer, remove observer and reset the state of the VC
    [self.finishTimer invalidate];
    [self.videoRecordTimer invalidate];
    [self.captureStatusLabel setText:@"RECORDING"];
    self.captureStatusLabel.textColor = [UIColor redColor];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{

    // video wasn't long enough. do nothing here but dismiss.
    if (!self.videoIsLongEnough) {
        return;
    }
    
    // save the video to disk
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    NSLog(@"%@ - %@", videoURL, mediaType);
    
    if (CFStringCompare((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)
    {
        NSString *moviePath = [[info objectForKey: UIImagePickerControllerMediaURL] path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath))
        {
            UISaveVideoAtPathToSavedPhotosAlbum (moviePath, nil, nil, nil);
        }
    }
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self vibrate];
    }];
}

- (void)startCameraCapture
{
    if ([self startVideoCapture]){
        self.finishTimer = [NSTimer scheduledTimerWithTimeInterval:7 target:self selector:@selector(timerFinished) userInfo:nil repeats:NO];
        [self.videoRecordTimer invalidate];
    }
}

- (void)timerFinished{
    [self stopVideoCapture];
    self.videoIsLongEnough = YES;
}

- (void)vibrate{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

- (void)dismissVC{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
