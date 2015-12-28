//
//  PlaybackViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "PlaybackViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import <Parse/Parse.h>

@interface PlaybackViewController ()
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) NSArray *videos;
@property (nonatomic, strong) PFObject *currentVideo;
@property (nonatomic, strong) NSTimer *pollPlayerTimer;
@property (nonatomic, strong) UIProgressView *progressBar;
@property (nonatomic, strong) UIImageView *reactionImageView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *cameraPreviewLayer;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) NSInteger videoPlayCount;
@property (nonatomic) BOOL canTakeReaction;
@end

@implementation PlaybackViewController

- (instancetype)initWithVideoArray:(NSArray *)videos{
    if (self = [super init]) {
        self.videoPlayCount = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        
        // dismiss gesture.
        UISwipeGestureRecognizer *swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissVC)];
        swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
        [self.view addGestureRecognizer:swipeDownGesture];
        
        // reverse the videos so we see oldest first
        self.videos = [[videos reverseObjectEnumerator] allObjects];
        
        // load up the first video, then start the player to go to the next.
        self.currentVideo = [self.videos objectAtIndex:self.videoPlayCount];
        PFFile *file = [self.currentVideo valueForKey:@"video"];
        
        NSURL *myURL = [NSURL URLWithString:file.url];
        
        self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:myURL];
        [self.moviePlayer.view setFrame:self.view.bounds];
        [self.moviePlayer setControlStyle:MPMovieControlStyleNone];
        [self.moviePlayer prepareToPlay];
        [self.moviePlayer setShouldAutoplay:YES];
        [self.view addSubview:self.moviePlayer.view];
        
        UIButton *nextButton = [[UIButton alloc] initWithFrame:self.view.frame];
        [nextButton setBackgroundColor:[UIColor clearColor]];
        [nextButton setTitle:@"" forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(playbackFinished) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:nextButton];
        
        self.progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        [self.view addSubview:self.progressBar];
        
        [self.progressBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
            make.left.right.equalTo(self.view);
        }];
        
        UIView *reactionLayer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame)/3, CGRectGetHeight(self.view.frame)/3)];
        [self.view addSubview:reactionLayer];
        
        [reactionLayer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom).with.offset(10);
            make.right.equalTo(self.view).with.offset(-10);
            make.height.equalTo(@(CGRectGetHeight(self.view.frame)/3));
            make.width.equalTo(@(CGRectGetWidth(self.view.frame)/3));
        }];
        
        [self beginPlayerPolling];
        
        AVCaptureSession *session = [[AVCaptureSession alloc] init];
        session.sessionPreset = AVCaptureSessionPresetHigh;
        
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        
        // only use the front facing camera
        AVCaptureDevice *device = [devices objectAtIndex:1];
        
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        
        if (!input) {
            NSLog(@"Couldn't create video capture device");
        }
        [session addInput:input];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
            UIView *view = reactionLayer;
            CALayer *viewLayer = [view layer];
            
            newCaptureVideoPreviewLayer.frame = view.bounds;
            
            [viewLayer addSublayer:newCaptureVideoPreviewLayer];
            
            self.cameraPreviewLayer = newCaptureVideoPreviewLayer;
            self.cameraPreviewLayer.borderColor = [UIColor blackColor].CGColor;
            self.cameraPreviewLayer.borderWidth = 1;
            
            self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
            NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
            [self.stillImageOutput setOutputSettings:outputSettings];
            
            [session addOutput:self.stillImageOutput];
            
            [session startRunning];
            
            UIButton *reactButton = [UIButton new];
            [reactButton setBackgroundColor:[UIColor blackColor]];
            [reactButton setTitle:@"REACT" forState:UIControlStateNormal];
            [reactionLayer addSubview:reactButton];
            
            [reactButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(reactionLayer);
                make.left.right.equalTo(reactionLayer);
                make.height.equalTo(@30);
            }];
            
            self.reactionImageView = [UIImageView new];
            [reactionLayer addSubview:self.reactionImageView];
            
            [self.reactionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(reactionLayer);
            }];
            
            UIButton *captureButton = [UIButton new];
            [captureButton setBackgroundColor:[UIColor clearColor]];
            [captureButton setTitle:@"" forState:UIControlStateNormal];
            [captureButton addTarget:self action:@selector(captureReaction) forControlEvents:UIControlEventTouchUpInside];
            [reactionLayer addSubview:captureButton];
            
            [captureButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(reactionLayer);
            }];
            
            self.canTakeReaction = YES;
            
        });
    }
    
    return self;
}

- (void)beginPlayerPolling{
    self.pollPlayerTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                            target:self
                                                          selector:@selector(pollTimerTick:)
                                                          userInfo:nil
                                                           repeats:YES];
    
}

- (void)pollTimerTick:(NSObject *)sender {
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying && self.moviePlayer.currentPlaybackTime != 0.f){
        [self.progressBar setProgress:self.moviePlayer.currentPlaybackTime / self.moviePlayer.duration];
    }else{
        [self.progressBar setProgress:0.0f];
    }
}

- (void)endPlayerPolling {
    if (self.pollPlayerTimer != nil){
        [self.pollPlayerTimer invalidate];
        self.pollPlayerTimer = nil;
    }
}

- (void)playbackFinished{
    if(self.currentVideo){
        NSMutableArray *recipientsReadIds = [NSMutableArray arrayWithArray:[self.currentVideo objectForKey:@"recipientsUnreadIds"]];
        [recipientsReadIds removeObject:[[PFUser currentUser] objectId]];
        [self.currentVideo setObject:recipientsReadIds forKey:@"recipientsUnreadIds"];
        [self.currentVideo saveInBackground];
    }
    
    // update our video play count since we achieved one.
    self.videoPlayCount++;
    
    // queue up the next one if we can
    if (self.videoPlayCount < self.videos.count){
        self.currentVideo = [self.videos objectAtIndex:self.videoPlayCount];
        
        PFFile *file = [self.currentVideo valueForKey:@"video"];
        NSURL *myURL = [NSURL URLWithString:file.url];
        [self.moviePlayer setContentURL:myURL];
        [self.moviePlayer play];
    }else{
        // no more queues, we should update what videos have been watches then dismiss
        [self dismissVC];
    }
}

- (void)captureReaction{
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying && self.canTakeReaction){
        self.canTakeReaction = NO;
        
        AVCaptureConnection *videoConnection = nil;
        for (AVCaptureConnection *connection in self.stillImageOutput.connections){
            for (AVCaptureInputPort *port in [connection inputPorts]){
                if ([[port mediaType] isEqual:AVMediaTypeVideo]){
                    videoConnection = connection;
                    break;
                }
            }
            if (videoConnection){
                break;
            }
        }
        
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error){
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            UIImage *flippedImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeftMirrored];
            
            self.reactionImageView.image = flippedImage;
            
            UIImage *reactionToUpload = [self mergeReactionImage:flippedImage withVideoCapture:[self.moviePlayer thumbnailImageAtTime:self.moviePlayer.currentPlaybackTime timeOption:MPMovieTimeOptionExact]];
            
            // save the compiled image to our albums for debug purposes. Should upload this to our shiznit.
            UIImageWriteToSavedPhotosAlbum(reactionToUpload, nil, nil, nil);
            
            [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(resetReaction) userInfo:nil repeats:NO];
        }];
    }
}

- (void)resetReaction{
    self.reactionImageView.image = nil;
    self.canTakeReaction = YES;
}

- (void)dismissVC{
    [self endPlayerPolling];
    [self.moviePlayer stop];
    
    // clear out the watched video ID's.
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (UIImage *)mergeReactionImage:(UIImage *)reactionImage withVideoCapture:(UIImage *)videoCaptureImage
{
    
    UIImage *newImage;
    
    CGRect rectVideoCapture = CGRectMake(0, 0, videoCaptureImage.size.width, videoCaptureImage.size.height);
    CGRect rectReactionCapture = CGRectMake(((videoCaptureImage.size.width/3) * 2) - 10, 10, videoCaptureImage.size.width/3, videoCaptureImage.size.height/3);

    // Begin context
    UIGraphicsBeginImageContextWithOptions(rectVideoCapture.size, NO, 0);
    
    // draw images
    [videoCaptureImage drawInRect:rectVideoCapture];
    [reactionImage drawInRect:rectReactionCapture];

    // grab context
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
