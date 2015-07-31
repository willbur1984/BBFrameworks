//
//  BBMediaPickerAssetGroupViewModel.m
//  BBFrameworks
//
//  Created by William Towe on 7/29/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "BBMediaPickerAssetsGroupViewModel.h"
#import "BBMediaPickerAssetViewModel.h"
#import "UIImage+BBKitExtensionsPrivate.h"
#import "BBMediaPickerViewModel.h"
#import "BBBlocks.h"
#import "BBFrameworksFunctions.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

#import <AssetsLibrary/AssetsLibrary.h>

@interface BBMediaPickerAssetsGroupViewModel ()
@property (readwrite,copy,nonatomic) NSString *detailCountString;
@property (readwrite,weak,nonatomic) BBMediaPickerViewModel *parentViewModel;
@property (readwrite,nonatomic) ALAssetsGroup *assetsGroup;
@end

@implementation BBMediaPickerAssetsGroupViewModel
#pragma mark *** Public Methods ***
- (instancetype)initWithAssetsGroup:(ALAssetsGroup *)assetsGroup parentViewModel:(BBMediaPickerViewModel *)parentViewModel; {
    if (!(self = [super init]))
        return nil;
    
    NSParameterAssert(assetsGroup);
    NSParameterAssert(parentViewModel);
    
    [self setAssetsGroup:assetsGroup];
    [self setParentViewModel:parentViewModel];
    
    if (self.parentViewModel.mediaTypes == BBMediaPickerMediaTypesPhoto) {
        [self.assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    }
    else if (self.parentViewModel.mediaTypes == BBMediaPickerMediaTypesVideo) {
        [self.assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
    }
    else {
        [self.assetsGroup setAssetsFilter:[ALAssetsFilter allAssets]];
    }
    
    return self;
}

- (void)refreshAssetViewModels {
    [self willChangeValueForKey:@keypath(self,name)];
    [self willChangeValueForKey:@keypath(self,countString)];
    [self willChangeValueForKey:@keypath(self,detailCountString)];
    _detailCountString = nil;
    [self didChangeValueForKey:@keypath(self,name)];
    [self didChangeValueForKey:@keypath(self,countString)];
    [self didChangeValueForKey:@keypath(self,detailCountString)];
}

- (RACSignal *)assetViewModels; {
    return [[[self rac_signalForSelector:@selector(refreshAssetViewModels)]
             startWith:nil]
            flattenMap:^RACStream *(id _) {
                return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                    NSMutableArray *temp = [[NSMutableArray alloc] init];
                    
                    [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if (result) {
                            [temp addObject:[[BBMediaPickerAssetViewModel alloc] initWithAsset:result]];
                        }
                        else {
                            [subscriber sendNext:[[temp BB_filter:^BOOL(BBMediaPickerAssetViewModel *object, NSInteger index) {
                                return ((object.type == BBMediaPickerAssetViewModelTypePhoto &&
                                         self.parentViewModel.mediaTypes & BBMediaPickerMediaTypesPhoto) ||
                                        (object.type == BBMediaPickerAssetViewModelTypeVideo &&
                                         self.parentViewModel.mediaTypes & BBMediaPickerMediaTypesVideo) ||
                                        (object.type == BBMediaPickerAssetViewModelTypeUnknown &&
                                         self.parentViewModel.mediaTypes & BBMediaPickerMediaTypesUnknown));
                            }] BB_filter:^BOOL(BBMediaPickerAssetViewModel *object, NSInteger index) {
                                return !self.parentViewModel.mediaFilterBlock || self.parentViewModel.mediaFilterBlock(object);
                            }]];
                            [subscriber sendCompleted];
                        }
                    }];
                    return nil;
                }];
            }];
}
#pragma mark Properties
- (NSURL *)URL {
    return [self.assetsGroup valueForProperty:ALAssetsGroupPropertyURL];
}
- (BBMediaPickerAssetsGroupViewModelType)type {
    return [[self.assetsGroup valueForProperty:ALAssetsGroupPropertyType] integerValue];
}
- (UIImage *)badgeImage {
    switch (self.type) {
        case BBMediaPickerAssetsGroupViewModelTypeSavedPhotos:
            return [UIImage BB_imageInResourcesBundleNamed:@"media_picker_camera_roll"];
        default:
            return nil;
    }
}
- (UIImage *)posterImage {
    return [UIImage imageWithCGImage:self.assetsGroup.posterImage];
}
- (UIImage *)secondPosterImage {
    __block UIImage *retval = nil;
    
    if (self.assetsGroup.numberOfAssets >= 2) {
        [self.assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] options:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                retval = [UIImage imageWithCGImage:result.thumbnail];
                *stop = YES;
            }
        }];
    }
    
    return retval;
}
- (UIImage *)thirdPosterImage {
    __block UIImage *retval = nil;
    
    if (self.assetsGroup.numberOfAssets >= 3) {
        [self.assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] options:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                retval = [UIImage imageWithCGImage:result.thumbnail];
                *stop = YES;
            }
        }];
    }
    
    return retval;
}
- (NSString *)name {
    return [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
}
- (NSInteger)count {
    return self.assetsGroup.numberOfAssets;
}
- (NSString *)countString {
    return @(self.count).stringValue;
}
- (NSString *)detailCountString {
    if (!_detailCountString) {
        __block NSInteger photos = 0, videos = 0;
        
        [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                photos++;
            }
            else if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                videos++;
            }
        }];
        
        NSMutableArray *comps = [[NSMutableArray alloc] init];
        
        if (photos == 1) {
            [comps addObject:[NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"MEDIA_PICKER_SINGLE_PHOTO_FORMAT", @"MediaPicker", BBFrameworksResourcesBundle(), @"%@ Photo", @"Media picker single photo format"),@(photos)]];
        }
        else if (photos > 1) {
            [comps addObject:[NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"MEDIA_PICKER_MULTIPLE_PHOTO_FORMAT", @"MediaPicker", BBFrameworksResourcesBundle(), @"%@ Photos", @"Media picker multiple photo format"),@(photos)]];
        }
        
        if (videos == 1) {
            [comps addObject:[NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"MEDIA_PICKER_SINGLE_VIDEO_FORMAT", @"MediaPicker", BBFrameworksResourcesBundle(), @"%@ Video", @"Media picker single video format"),@(videos)]];
        }
        else if (videos > 1) {
            [comps addObject:[NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"MEDIA_PICKER_MULTIPLE_VIDEO_FORMAT", @"MediaPicker", BBFrameworksResourcesBundle(), @"%@ Videos", @"Media picker multiple video format"),@(videos)]];
        }
        
        _detailCountString = [comps componentsJoinedByString:@", "];
    }
    return _detailCountString;
}

@end
