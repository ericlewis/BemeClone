//
//  CaptureViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "CaptureViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Parse/Parse.h>

@interface CaptureViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) NSTimer *finishTimer;
@property (nonatomic, strong) BaseLabel *captureStatusLabel;
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
    if ([[UIDevice currentDevice] proximityState] == NO){
        [self stopVideoCapture];

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
    [self performSelector:@selector(startRecording) withObject:nil afterDelay:0.6];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)
                                                 name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // schedule a timer yo.
    self.finishTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(stopRecording) userInfo:nil repeats:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.finishTimer invalidate];
    [self.captureStatusLabel setText:@"RECORDING"];
    self.captureStatusLabel.textColor = [UIColor redColor];
    [self stopVideoCapture];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSLog(@"%@", info);
    
    if (!self.finishTimer.valid) {
        [self vibrate];

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
        
        // Convert to Video data.
        
        NSData *imageData = [NSData dataWithContentsOfURL:videoURL];        
        PFFile *videofile = [PFFile fileWithName:@"video.mov" data:imageData];
        
        [videofile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (!error) {
                [self dismissViewControllerAnimated:NO completion:nil];
            }else{
                NSLog(@"%@", error);
            }
        }];
        
    }else{
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        
        // delete the file.
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:videoURL.path]) {
            NSError *error;
            if ([fileManager removeItemAtPath:[videoURL.path stringByDeletingLastPathComponent] error:&error] != YES) {
                NSLog(@"Unable to delete file: %@", [error localizedDescription]);
            }
        }
        
        [self dismissViewControllerAnimated:NO completion:nil];

    }
}

- (void)vibrate{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

- (void)startRecording{
    [self startVideoCapture];
    
}

- (void)stopRecording{
    [self.finishTimer invalidate];
    [self stopVideoCapture];
    [self performSelector:@selector(vibrate) withObject:nil afterDelay:0.3];
}

@end
