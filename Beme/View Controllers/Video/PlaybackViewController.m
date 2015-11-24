//
//  PlaybackViewController.m
//  Beme
//
//  Created by Eric Lewis on 11/22/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "PlaybackViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PlaybackViewController ()
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@end

@implementation PlaybackViewController

- (instancetype)initWithVideoURLString:(NSString*)urlString{
    if (self = [super init]) {
        NSURL *myURL = [NSURL URLWithString:urlString];
        
        self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:myURL];
        [self.moviePlayer.view setFrame:self.view.bounds];
        [self.moviePlayer setControlStyle:MPMovieControlStyleNone];
        [self.moviePlayer prepareToPlay];
        [self.moviePlayer setShouldAutoplay:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];

        [self.view addSubview:self.moviePlayer.view];
    }
    
    return self;
}

- (void)playbackFinished{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
