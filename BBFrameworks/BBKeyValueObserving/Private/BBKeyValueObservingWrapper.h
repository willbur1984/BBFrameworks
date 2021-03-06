//
//  BBKeyValueObservingWrapper.h
//  BBFrameworks
//
//  Created by William Towe on 9/24/15.
//  Copyright © 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Foundation/Foundation.h>
#import "BBKeyValueObservingDefines.h"
#import "BBKeyValueObservingToken.h"

NS_ASSUME_NONNULL_BEGIN

/**
 BBKeyValueObservingWrapper is used internally to setup KVO on targets and invoke its block when changes occur. Just like KVO, references to the observer and target are unsafe_unretained.
 
 BBKeyValueObservingWrapper conforms to BBKeyValueObservingToken to allow manually stopping observation.
 */
@interface BBKeyValueObservingWrapper : NSObject <BBKeyValueObservingToken>

@property (readonly,unsafe_unretained,nonatomic,nullable) id observer;
@property (readonly,unsafe_unretained,nonatomic) id target;
@property (readonly,copy,nonatomic) NSSet *keyPaths;
@property (readonly,assign,nonatomic) NSKeyValueObservingOptions options;
@property (readonly,copy,nonatomic) BBKeyValueObservingBlock block;

- (instancetype)initWithObserver:(nullable id)observer target:(id)target keyPaths:(NSSet *)keyPaths options:(NSKeyValueObservingOptions)options block:(BBKeyValueObservingBlock)block NS_DESIGNATED_INITIALIZER;

- (instancetype)init __attribute__((unavailable("use initWithObserver:target:keyPaths:options:block: instead")));

@end

NS_ASSUME_NONNULL_END
