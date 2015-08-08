//
//  BBMediaPickerAssetCollectionViewCellSelectedOverlayView.h
//  BBFrameworks
//
//  Created by William Towe on 8/7/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <UIKit/UIKit.h>

@interface BBMediaPickerAssetCollectionViewCellSelectedOverlayView : UIView

/**
 Set and get whether the receiver is highlighted. This will get set automatically by the owning collection view cell.
 */
@property (assign,nonatomic,getter=isHighlighted) BOOL highlighted;

/**
 Set and get the selected overlay foreground color. This used to draw the border around the checkmark as well as the checkmark itself.
 
 The default is [UIColor whiteColor].
 */
@property (strong,nonatomic) UIColor *selectedOverlayForegroundColor UI_APPEARANCE_SELECTOR;
/**
 Set and get the selected overlay tint color. This affects the checkmark that is drawn within the selected overlay when the represented view model is selected. If nil, the tintColor of the receiver is used.
 
 The default is nil.
 */
@property (strong,nonatomic) UIColor *selectedOverlayTintColor UI_APPEARANCE_SELECTOR;
/**
 Set and get the selected overlay background color. This is the view that is placed over the thumbnail image when the represented view model is selected.
 
 The default is BBColorWA(1.0, 0.33).
 */
@property (strong,nonatomic) UIColor *selectedOverlayBackgroundColor UI_APPEARANCE_SELECTOR;

@end