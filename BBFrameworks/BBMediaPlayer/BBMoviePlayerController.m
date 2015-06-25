//
//  BBMoviePlayerController.m
//  BBFrameworks
//
//  Created by William Towe on 6/22/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "BBMoviePlayerController.h"
#import "BBMoviePlayerView.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

#import <AVFoundation/AVFoundation.h>

static int32_t const kPreferredTimeScale = 1;

@interface BBMoviePlayerController ()
@property (strong,nonatomic) BBMoviePlayerView *moviePlayerView;

@property (readwrite,strong,nonatomic) AVPlayer *player;
@end

@implementation BBMoviePlayerController
#pragma mark *** Subclass Overrides ***
- (instancetype)init {
    if (!(self = [super init]))
        return nil;
    
    [self setPlayer:[[AVPlayer alloc] init]];
    
    [self setMoviePlayerView:[[BBMoviePlayerView alloc] initWithMoviePlayerController:self]];
    
    @weakify(self);
    [[[RACObserve(self, contentURL)
     distinctUntilChanged]
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSURL *value) {
         @strongify(self);
         AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:value];
         
         [self.player replaceCurrentItemWithPlayerItem:playerItem];
         
         if (self.shouldAutoplay) {
             [self play];
         }
     }];
    
    return self;
}
#pragma mark *** Public Methods ***
- (void)play {
    [self setCurrentPlaybackRate:1.0];
}
- (void)pause {
    [self setCurrentPlaybackRate:0.0];
}
- (void)stop {
    [self pause];
    [self setCurrentPlaybackTime:0.0];
}
#pragma mark Properties
- (UIView *)view {
    return self.moviePlayerView;
}
- (UIView *)backgroundView {
    return self.moviePlayerView.backgroundView;
}

@dynamic currentPlaybackTime;
- (NSTimeInterval)currentPlaybackTime {
    return CMTimeGetSeconds(self.player.currentTime);
}
- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    [self willChangeValueForKey:@keypath(self,currentPlaybackTime)];
    
    [self.player seekToTime:CMTimeMakeWithSeconds(currentPlaybackTime, kPreferredTimeScale)];
    
    [self didChangeValueForKey:@keypath(self,currentPlaybackTime)];
}

@dynamic currentPlaybackRate;
- (CGFloat)currentPlaybackRate {
    return self.player.rate;
}
- (void)setCurrentPlaybackRate:(CGFloat)currentPlaybackRate {
    [self willChangeValueForKey:@keypath(self,currentPlaybackRate)];
    
    [self.player setRate:currentPlaybackRate];
    
    [self didChangeValueForKey:@keypath(self,currentPlaybackRate)];
}

@end
