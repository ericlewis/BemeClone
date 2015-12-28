//
//  ReactionViewController.m
//  Beme
//
//  Created by Eric Lewis on 12/28/15.
//  Copyright © 2015 Eric Lewis. All rights reserved.
//

#import "ReactionViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <Parse/Parse.h>
#import "Constants.h"

@interface ReactionViewController ()
@property (nonatomic, strong) NSArray *reactions;
@property (nonatomic, strong) PFObject *currentReaction;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *endOfReactionsView;

@property (nonatomic) NSInteger reactionViewCount;

@end

@implementation ReactionViewController

- (instancetype)initWithReactionArray:(NSArray*)reactions{
    if (self = [super init]) {
        self.reactions = reactions;
        
        UIView *superview = self.view;
        
        self.imageView = [UIImageView new];
        [superview addSubview:self.imageView];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(superview);
        }];
        
        // username label
        self.usernameLabel = [UILabel new];
        [self.usernameLabel setTextColor:[UIColor blackColor]];
        [superview addSubview:self.usernameLabel];
        
        [self.usernameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.left.equalTo(self.imageView);
        }];
        
        UIButton *nextButton = [UIButton new];
        [nextButton setBackgroundColor:[UIColor clearColor]];
        [nextButton setTitle:@"" forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(showNextReaction) forControlEvents:UIControlEventTouchUpInside];
        [superview addSubview:nextButton];
        
        [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(superview);
        }];
        
        self.endOfReactionsView = [UILabel new];
        [self.endOfReactionsView setBackgroundColor:[UIColor blackColor]];
        [self.endOfReactionsView setTextColor:[UIColor whiteColor]];
        [self.endOfReactionsView setTextAlignment:NSTextAlignmentCenter];
        [self.endOfReactionsView setText:@"END"];
        [self.endOfReactionsView setHidden:YES];
        [self.endOfReactionsView setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
        [self.endOfReactionsView addGestureRecognizer:tapGesture];
        
        [superview addSubview:self.endOfReactionsView];
        
        [self.endOfReactionsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(superview);
        }];
        
        // dismiss button
        UIButton *dismissButton = [UIButton new];
        [dismissButton setTitle:@"Close" forState:UIControlStateNormal];
        [dismissButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [dismissButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
        [superview addSubview:dismissButton];
        
        [dismissButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.right.equalTo(self.imageView);
        }];
        
        // setup the first reaction
        self.currentReaction = [self.reactions objectAtIndex:0];
        
        self.usernameLabel.text = [self.currentReaction valueForKey:kReactionSenderNameKey];
        PFFile *firstReaction = [self.currentReaction valueForKey:kReactionFileKey];
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:firstReaction.url]];
    }
    
    return self;
}

- (void)showNextReaction{
    if(self.currentReaction){
        NSMutableArray *recipientsReadIds = [NSMutableArray arrayWithArray:[self.currentReaction objectForKey:kReactionRecipientsUnreadIdKey]];
        [recipientsReadIds removeObject:[[PFUser currentUser] objectId]];
        [self.currentReaction setObject:recipientsReadIds forKey:kReactionRecipientsUnreadIdKey];
        [self.currentReaction saveInBackground];
    }
    
    // update our video play count since we achieved one.
    self.reactionViewCount++;
    
    // queue up the next one if we can
    if (self.reactionViewCount < self.reactions.count){
        self.currentReaction = [self.reactions objectAtIndex:self.reactionViewCount];
        
        PFFile *file = [self.currentReaction valueForKey:kReactionFileKey];
        NSURL *myURL = [NSURL URLWithString:file.url];
        [self.imageView sd_setImageWithURL:myURL];
    }else{
        // no more queues, lets show the end screen then dismiss.
        [self.endOfReactionsView setHidden:NO];
    }
}

- (void)dismissView{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
