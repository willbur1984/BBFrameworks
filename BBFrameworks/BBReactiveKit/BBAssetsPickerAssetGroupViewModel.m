//
//  BBAssetsPickerAssetGroupViewModel.m
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

#import "BBAssetsPickerAssetGroupViewModel.h"
#import "BBAssetsPickerAssetViewModel.h"
#import "BBFoundationDebugging.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

#import <AssetsLibrary/AssetsLibrary.h>

@interface BBAssetsPickerAssetGroupViewModel ()
@property (readwrite,copy,nonatomic) NSArray *assetViewModels;
@property (readwrite,copy,nonatomic) NSArray *selectedAssetViewModels;

@property (readwrite,strong,nonatomic) RACCommand *doneCommand;

@property (strong,nonatomic) ALAssetsGroup *assetsGroup;
@end

@implementation BBAssetsPickerAssetGroupViewModel
#pragma mark *** Public Methods ***
- (instancetype)initWithAssetsGroup:(ALAssetsGroup *)assetsGroup; {
    if (!(self = [super init]))
        return nil;
    
    NSParameterAssert(assetsGroup);
    
    [self setAssetsGroup:assetsGroup];
    
    @weakify(self);
    [self setDoneCommand:[[RACCommand alloc] initWithEnabled:[RACObserve(self, selectedAssetViewModels) map:^id(NSArray *value) {
        return @(value.count > 0);
    }] signalBlock:^RACSignal *(id input) {
        @strongify(self);
        return [RACSignal return:self];
    }]];
    
    return self;
}

- (void)reloadAssetViewModels; {
    NSMutableArray *assetViewModels = [[NSMutableArray alloc] init];
    
    [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [assetViewModels addObject:[[BBAssetsPickerAssetViewModel alloc] initWithAsset:result]];
        }
    }];
    
    [self setAssetViewModels:assetViewModels.count > 0 ? assetViewModels : nil];
    
    [self setSelectedAssetViewModels:nil];
}

- (void)selectAssetViewModel:(BBAssetsPickerAssetViewModel *)viewModel; {
    NSMutableOrderedSet *temp = [NSMutableOrderedSet orderedSetWithArray:self.selectedAssetViewModels];
    
    [temp addObject:viewModel];
    
    [self setSelectedAssetViewModels:temp.array];
}
- (void)deselectAssetViewModel:(BBAssetsPickerAssetViewModel *)viewModel; {
    NSMutableOrderedSet *temp = [NSMutableOrderedSet orderedSetWithArray:self.selectedAssetViewModels];
    
    [temp removeObject:viewModel];
    
    [self setSelectedAssetViewModels:temp.array];
}
#pragma mark Properties
- (NSURL *)URL {
    return [self.assetsGroup valueForProperty:ALAssetsGroupPropertyURL];
}

- (NSString *)name {
    return [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
}
- (UIImage *)thumbnailImage {
    return [UIImage imageWithCGImage:self.assetsGroup.posterImage];
}

- (NSArray *)assetViewModels {
    if (!_assetViewModels) {
        [self reloadAssetViewModels];
    }
    return _assetViewModels;
}

@end
