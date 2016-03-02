//
//  BBMediaViewerPagePDFModel.h
//  BBFrameworks
//
//  Created by William Towe on 3/1/16.
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
#import "BBMediaViewerPagePDFModelDelegate.h"
#import <CoreGraphics/CGPDFPage.h>

NS_ASSUME_NONNULL_BEGIN

@class BBMediaViewerPagePDFDetailModel,BBThumbnailGenerator;

@interface BBMediaViewerPagePDFModel : BBMediaViewerPageModel

@property (weak,nonatomic,nullable) id<BBMediaViewerPagePDFModelDelegate> delegate;

@property (readonly,nonatomic) size_t numberOfPages;
@property (readonly,assign,nonatomic) size_t selectedPage;

@property (readonly,strong,nonatomic) BBThumbnailGenerator *thumbnailGenerator;
@property (readonly,nonatomic) CGSize thumbnailSize;

- (BBMediaViewerPagePDFDetailModel *)pagePDFDetailForPage:(size_t)page;

- (void)selectPagePDFDetail:(BBMediaViewerPagePDFDetailModel *)pagePDFDetail;
- (void)selectPagePDFDetail:(BBMediaViewerPagePDFDetailModel *)pagePDFDetail notifyDelegate:(BOOL)notifyDelegate;

@end

NS_ASSUME_NONNULL_END
