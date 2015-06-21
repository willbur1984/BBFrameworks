//
//  BBAssetsPickerAssetViewModel.m
//  BBFrameworks
//
//  Created by William Towe on 6/19/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "BBAssetsPickerAssetViewModel.h"
#import "BBMediaPickerCollectionViewModel.h"
#import "BBMediaPickerViewModel.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

#import <Photos/Photos.h>

@interface BBAssetsPickerAssetViewModel ()
@property (strong,nonatomic) PHAsset *asset;
@property (weak,nonatomic) BBMediaPickerCollectionViewModel *assetsGroupViewModel;
@end

@implementation BBAssetsPickerAssetViewModel

- (RACSignal *)requestAssetImageIncludingEdits:(BOOL)includeEdits progressBlock:(void(^)(CGFloat progress))progressBlock; {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        
        [options setVersion:includeEdits ? PHImageRequestOptionsVersionCurrent : PHImageRequestOptionsVersionOriginal];
        [options setDeliveryMode:PHImageRequestOptionsDeliveryModeHighQualityFormat];
        [options setNetworkAccessAllowed:YES];
        
        if (progressBlock) {
            [options setProgressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info){
                progressBlock(progress);
            }];
        }
        
        PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            if (result) {
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:info[PHImageErrorKey]];
            }
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [[PHImageManager defaultManager] cancelImageRequest:requestID];
        }];
    }];
}

- (instancetype)initWithAsset:(PHAsset *)asset assetsGroupViewModel:(BBMediaPickerCollectionViewModel *)assetsGroupViewModel {
    if (!(self = [super init]))
        return nil;
    
    NSParameterAssert(asset);
    NSParameterAssert(assetsGroupViewModel);
    
    [self setAsset:asset];
    [self setAssetsGroupViewModel:assetsGroupViewModel];
    
    return self;
}

- (RACSignal *)requestThumbnailImageWithSize:(CGSize)size; {
    return [self.assetsGroupViewModel.viewModel requestThumbnailImageForAsset:self.asset size:size];
}

@end
