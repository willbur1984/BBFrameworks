//
//  BBThumbnailRTFOperation.m
//  BBFrameworks
//
//  Created by William Towe on 5/30/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "BBThumbnailRTFOperation.h"
#if (TARGET_OS_IPHONE)
#import "UIImage+BBKitExtensions.h"
#else
#import <AppKit/AppKit.h>
#endif

@interface BBThumbnailRTFOperation ()
@property (strong,nonatomic) NSURL *URL;
@property (assign,nonatomic) BBThumbnailGeneratorSizeStruct size;
@property (copy,nonatomic) BBThumbnailOperationCompletionBlock operationCompletionBlock;
@end

@implementation BBThumbnailRTFOperation

- (void)main {
    if (self.isCancelled) {
        self.operationCompletionBlock(nil,nil);
        return;
    }
    
    NSError *outError;
#if (TARGET_OS_IPHONE)
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithFileURL:self.URL options:@{NSDocumentTypeDocumentAttribute: [self.URL.lastPathComponent.pathExtension isEqualToString:@"rtfd"] ? NSRTFDTextDocumentType : NSRTFTextDocumentType} documentAttributes:nil error:&outError];
#else
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithURL:self.URL options:@{NSDocumentTypeDocumentAttribute: [self.URL.lastPathComponent.pathExtension isEqualToString:@"rtfd"] ? NSRTFDTextDocumentType : NSRTFTextDocumentType} documentAttributes:nil error:&outError];
#endif
    
    if (!attributedString) {
        self.operationCompletionBlock(nil,outError);
        return;
    }
    
#if (TARGET_OS_IPHONE)
    CGSize const kSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    
    UIGraphicsBeginImageContextWithOptions(kSize, YES, 0);
    
    UIColor *backgroundColor = [attributedString attribute:NSBackgroundColorAttributeName atIndex:0 effectiveRange:NULL] ?: [UIColor whiteColor];
    
    [backgroundColor setFill];
    UIRectFill(CGRectMake(0, 0, kSize.width, kSize.height));
    
    [attributedString drawWithRect:CGRectMake(0, 0, kSize.width, kSize.height) options:NSStringDrawingUsesLineFragmentOrigin context:NULL];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImage *retval = [image BB_imageByResizingToSize:self.size];
#else
    NSImage *retval = [[NSImage alloc] initWithSize:self.size];
    
    [retval lockFocus];
    
    [attributedString drawAtPoint:NSZeroPoint];
    
    [retval unlockFocus];
#endif
    
    self.operationCompletionBlock(retval,nil);
}

- (instancetype)initWithURL:(NSURL *)URL size:(BBThumbnailGeneratorSizeStruct)size completion:(BBThumbnailOperationCompletionBlock)completion; {
    if (!(self = [super init]))
        return nil;
    
    [self setURL:URL];
    [self setSize:size];
    [self setOperationCompletionBlock:completion];
    
    return self;
}

@end
