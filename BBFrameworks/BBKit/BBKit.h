//
//  BBKit.h
//  BBFrameworks
//
//  Created by William Towe on 5/13/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#ifndef __BB_FRAMEWORKS_KIT__
#define __BB_FRAMEWORKS_KIT__

#import <BBFrameworks/BBKitColorMacros.h>

#import <BBFrameworks/NSURL+BBKitExtensions.h>
#if (TARGET_OS_IPHONE)
#import <BBFrameworks/UIImage+BBKitExtensions.h>
#import <BBFrameworks/UIView+BBKitExtensions.h>
#import <BBFrameworks/UIViewController+BBKitExtensions.h>
#import <BBFrameworks/UIFont+BBKitExtensions.h>
#import <BBFrameworks/UIBarButtonItem+BBKitExtensions.h>
#import <BBFrameworks/UIAlertController+BBKitExtensions.h>
#else
#import <BBFrameworks/NSImage+BBKitExtensions.h>
#import <BBFrameworks/NSAlert+BBKitExtensions.h>
#endif

#import <BBFrameworks/BBBadgeView.h>
#import <BBFrameworks/BBGradientView.h>
#import <BBFrameworks/BBView.h>
#import <BBFrameworks/BBTextField.h>
#import <BBFrameworks/BBTextFieldErrorView.h>
#endif
