//
//  BBMediaViewerPageModel.m
//  BBFrameworks
//
//  Created by William Towe on 2/28/16.
//  Copyright © 2016 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "BBMediaViewerPageModel.h"
#import "BBMediaViewerModel.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface BBMediaViewerPageModel ()
@property (readwrite,strong,nonatomic) id<BBMediaViewerMedia> media;
@property (readwrite,assign,nonatomic) BBMediaViewerPageModelType type;
@property (readwrite,weak,nonatomic) BBMediaViewerModel *parentModel;
@end

@implementation BBMediaViewerPageModel

- (instancetype)initWithMedia:(id<BBMediaViewerMedia>)media parentModel:(BBMediaViewerModel *)parentModel; {
    if (!(self = [super init]))
        return nil;
    
    NSParameterAssert(media);
    NSParameterAssert(parentModel);
    
    _media = media;
    _type = [self.class typeForMedia:_media];
    _parentModel = parentModel;
    
    return self;
}

+ (BBMediaViewerPageModelType)typeForMedia:(id<BBMediaViewerMedia>)media; {
    NSURL *URL = media.mediaViewerMediaURL;
    NSString *UTI = nil;
    
    if ([media respondsToSelector:@selector(mediaViewerMIMEType)]) {
        UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)[media mediaViewerMIMEType], NULL);
    }
    else {
        UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)URL.pathExtension, NULL);
    }
    
    if (UTTypeConformsTo((__bridge CFStringRef)UTI, kUTTypeGIF)) {
        return BBMediaViewerPageModelTypeImageAnimated;
    }
    else if (UTTypeConformsTo((__bridge CFStringRef)UTI, kUTTypeImage)) {
        return BBMediaViewerPageModelTypeImage;
    }
    else if (UTTypeConformsTo((__bridge CFStringRef)UTI, kUTTypeMovie)) {
        return BBMediaViewerPageModelTypeMovie;
    }
    else if (UTTypeConformsTo((__bridge CFStringRef)UTI, kUTTypePDF)) {
        return BBMediaViewerPageModelTypePDF;
    }
    else if (UTTypeConformsTo((__bridge CFStringRef)UTI, kUTTypePlainText)) {
        return BBMediaViewerPageModelTypePlainText;
    }
    else if (UTTypeConformsTo((__bridge CFStringRef)UTI, kUTTypeRTFD)) {
        return BBMediaViewerPageModelTypeRTFD;
    }
    else if (UTTypeConformsTo((__bridge CFStringRef)UTI, kUTTypeRTF)) {
        return BBMediaViewerPageModelTypeRTF;
    }
    else if (URL.isFileURL &&
             [[NSSet setWithArray:@[@"doc",@"docx",@"ppt",@"pptx",@"xls",@"xlsx",@"key",@"numbers",@"pages"]] containsObject:URL.pathExtension.lowercaseString]) {
        
        return BBMediaViewerPageModelTypeDocument;
    }
    else if (UTTypeConformsTo((__bridge CFStringRef)UTI, kUTTypeHTML) ||
             UTTypeConformsTo((__bridge CFStringRef)UTI, kUTTypeURL)) {
        
        return BBMediaViewerPageModelTypeHTML;
    }
    else {
        return BBMediaViewerPageModelTypeUnknown;
    }
}

- (NSURL *)URL {
    return self.media.mediaViewerMediaURL;
}
- (NSString *)title {
    return [self.media respondsToSelector:@selector(mediaViewerMediaTitle)] ? self.media.mediaViewerMediaTitle : self.URL.lastPathComponent;
}
- (NSString *)UTI {
    if ([self.media respondsToSelector:@selector(mediaViewerMIMEType)]) {
        return (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)[self.media mediaViewerMIMEType], NULL);
    }
    else {
        return (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)self.URL.pathExtension, NULL);
    }
}
- (id)activityItem {
    return self.URL;
}

@end
