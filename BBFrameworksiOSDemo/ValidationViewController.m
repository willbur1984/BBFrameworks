//
//  ValidationViewController.m
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

#import "ValidationViewController.h"

#import <BBFrameworks/BBKit.h>
#import <BBFrameworks/BBValidation.h>
#import <BBFrameworks/BBFoundation.h>

@interface ValidationViewController ()
@property (weak,nonatomic) IBOutlet BBTextField *phoneNumberTextField;
@property (weak,nonatomic) IBOutlet BBTextField *customTextField;
@property (weak,nonatomic) IBOutlet BBTextView *textView;
@end

@implementation ValidationViewController

- (NSString *)title {
    return [self.class rowClassTitle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIEdgeInsets textEdgeInsets = UIEdgeInsetsMake(0, 8.0, 0, 8.0);
    UIEdgeInsets rightViewEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8.0);
    
    [self.phoneNumberTextField setTextEdgeInsets:textEdgeInsets];
    [self.phoneNumberTextField setRightViewEdgeInsets:rightViewEdgeInsets];
    [self.phoneNumberTextField BB_addTextValidator:[[BBTextPhoneNumberValidator alloc] init]];
    
    [self.customTextField setTextEdgeInsets:textEdgeInsets];
    [self.customTextField setRightViewEdgeInsets:rightViewEdgeInsets];
    [self.customTextField BB_addTextValidator:[[BBTextCustomValidator alloc] initWithValidatorBlock:^BOOL(BBTextCustomValidator *validator, NSString *text, NSError *__autoreleasing *error) {
        if (text.length > 0) {
            if (![text containsString:@"@"]) {
                [validator setTextValidatorRightView:[[BBValidationTextFieldErrorView alloc] initWithError:[NSError errorWithDomain:@"" code:0 userInfo:@{BBErrorAlertMessageKey: @"Please enter a valid email address."}]]];
                return NO;
            }
            else if (![text containsString:@"@gmail.com"]) {
                [validator setTextValidatorRightView:[[BBValidationTextFieldWarningView alloc] initWithError:[NSError errorWithDomain:@"" code:0 userInfo:@{BBErrorAlertMessageKey: @"Please enter a valid Gmail email address."}]]];
                return NO;
            }
        }
        return YES;
    }]];
    
    [self.textView.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.textView.layer setBorderWidth:1.0];
    [self.textView setTextContainerInset:UIEdgeInsetsMake(8.0, 8.0, 0, 8.0)];
    [self.textView setFont:[UIFont systemFontOfSize:17.0]];
    [self.textView setPlaceholder:@"Type a link…"];
    [self.textView BB_addTextValidator:[[BBTextLinkValidator alloc] init]];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.phoneNumberTextField becomeFirstResponder];
}

+ (NSString *)rowClassTitle {
    return @"Validation";
}

@end
