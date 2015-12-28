//
//  PlaybackViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "PlaybackViewController.h"
#import <MediaPlayer/MediaPlayer.h>

#import <Parse/Parse.h>

@interface PlaybackViewController ()
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) NSArray *videos;
@property (nonatomic, strong) PFObject *currentVideo;
@property (nonatomic, strong) NSTimer *pollPlayerTimer;
@property (nonatomic, strong) UIProgressView *progressBar;
@property (nonatomic) NSInteger videoPlayCount;
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
        
        [self beginPlayerPolling];
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

- (void)dismissVC{
    [self endPlayerPolling];
    [self.moviePlayer stop];
    
    // clear out the watched video ID's.
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
