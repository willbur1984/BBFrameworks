//
//  BBValidationTextFieldWarningView.m
//  BBFrameworks
//
//  Created by William Towe on 7/26/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "BBValidationTextFieldWarningView.h"
#import "BBKit.h"
#import "BBTooltip.h"
#import "BBValidationMacros.h"
#import "BBFoundation.h"

@interface _BBValidationWarningTooltipViewController : BBTooltipViewController

@end

@implementation _BBValidationWarningTooltipViewController

- (instancetype)init {
    if (!(self = [super init]))
        return nil;
    
    [self setTooltipOverlayBackgroundColor:[UIColor clearColor]];
    
    return self;
}

@end

#define kImageBackgroundColor() BBColorRGB(0.95, 0.95, 0)
#define kTextColor() [UIColor darkGrayColor]

@interface BBValidationTextFieldWarningView ()
@property (strong,nonatomic) UIButton *button;

@property (strong,nonatomic) NSError *error;
@end

@implementation BBValidationTextFieldWarningView

+ (void)initialize {
    if (self == [BBValidationTextFieldWarningView class]) {
        [[BBTooltipView appearanceWhenContainedIn:[_BBValidationWarningTooltipViewController class], nil] setTooltipTextColor:kTextColor()];
        [[BBTooltipView appearanceWhenContainedIn:[_BBValidationWarningTooltipViewController class], nil] setTooltipBackgroundColor:kImageBackgroundColor()];
    }
}

- (void)layoutSubviews {
    [self.button setFrame:self.bounds];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self.button sizeThatFits:size];
}

- (CGSize)intrinsicContentSize {
    return [self sizeThatFits:CGSizeZero];
}

- (instancetype)initWithError:(NSError *)error; {
    if (!(self = [super initWithFrame:CGRectZero]))
        return nil;
    
    [self setError:error];
    
    [self setButton:[UIButton buttonWithType:UIButtonTypeSystem]];
    [self.button setImage:({
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(22, 22), NO, 0);
        
        [kImageBackgroundColor() setFill];
        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 22, 22)] fill];
        
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        
        [style setAlignment:NSTextAlignmentCenter];
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:14.0], NSForegroundColorAttributeName: kTextColor(), NSParagraphStyleAttributeName: style};
        
        [BBValidationLocalizedWarningString() drawInRect:BBCGRectCenterInRectVertically(CGRectMake(0, 0, 22, ceil([BBValidationLocalizedWarningString() sizeWithAttributes:attributes].height)), CGRectMake(0, 0, 22, 22)) withAttributes:attributes];
        
        UIImage *image = [UIGraphicsGetImageFromCurrentImageContext() imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UIGraphicsEndImageContext();
        
        image;
    }) forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.button];
    
    return self;
}

- (IBAction)_buttonAction:(id)sender {
    [[UIViewController BB_viewControllerForPresenting] BB_presentTooltipViewControllerWithText:self.error.BB_alertMessage attachmentView:self attributes:@{BBTooltipAttributeViewControllerClass: [_BBValidationWarningTooltipViewController class]}];
}

@end
