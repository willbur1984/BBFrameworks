//
//  BBError.h
//  BBFrameworks
//
//  Created by Jason Anderson on 6/29/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Foundation/Foundation.h>

#if (TARGET_OS_IPHONE)
#import <UIKit/UIAlertController.h>
#else
#import <AppKit/NSAlert.h>
#endif

extern NSString *const BBErrorAlertTitleKey;
extern NSString *const BBErrorAlertMessageKey;

/**
 BBError is an NSError subclass with convenience methods for creating NSAlert/UIAlertController from the error message
 */
@interface BBError : NSError

@property (readonly, copy) NSString *alertTitle;
@property (readonly, copy) NSString *alertMessage;

@end

#if (TARGET_OS_IPHONE)
@interface UIAlertController (BBFoundationExtensions)

+ (UIAlertController *)BB_alertWithError:(NSError *)error;

@end
#else
@interface NSAlert (BBFoundationExtensions)

+ (NSAlert *)BB_alertWithError:(NSError *)error;

@end
#endif