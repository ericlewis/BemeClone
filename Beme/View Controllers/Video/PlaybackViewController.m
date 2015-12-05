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
@property (nonatomic) NSInteger videoPlayCount;
@end

@implementation PlaybackViewController

- (instancetype)initWithVideoArray:(NSArray *)videos{
    if (self = [super init]) {
        self.videoPlayCount = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        UISwipeGestureRecognizer *swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissVC)];
        swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
        [self.view addGestureRecognizer:swipeDownGesture];
        
        // reverse the videos so we see oldest first
        self.videos = [[videos reverseObjectEnumerator] allObjects];
        
        // load up the first video, then start the player to go to the next.
        PFFile *file = [[self.videos objectAtIndex:self.videoPlayCount] valueForKey:@"video"];

        NSURL *myURL = [NSURL URLWithString:file.url];
        
        self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:myURL];
        [self.moviePlayer.view setFrame:self.view.bounds];
        [self.moviePlayer setControlStyle:MPMovieControlStyleNone];
        [self.moviePlayer prepareToPlay];
        [self.moviePlayer setShouldAutoplay:YES];
        
        [self.view addSubview:self.moviePlayer.view];
    }
    
    return self;
}

- (void)playbackFinished{
    // update our video play count since we achieved one.
    self.videoPlayCount++;
    
    // queue up the next one if we can
    if (self.videoPlayCount < self.videos.count) {
        PFFile *file = [[self.videos objectAtIndex:self.videoPlayCount] valueForKey:@"video"];
        NSURL *myURL = [NSURL URLWithString:file.url];
        [self.moviePlayer setContentURL:myURL];
        [self.moviePlayer play];
    }else{
        [self dismissVC];
    }
}

- (void)dismissVC{
    [self.moviePlayer stop];
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
