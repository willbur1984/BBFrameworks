//
//  NSDictionary+BBBlockExtensions.h
//  BBFrameworks
//
//  Created by William Towe on 11/3/15.
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

NS_ASSUME_NONNULL_BEGIN

/**
 Category on NSDictionary adding block extensions.
 */
@interface NSDictionary (BBBlocksExtensions)

/**
 Invokes block once for each key/value pair in the receiver.
 
 @param block The block to invoke for each key/value pair
 @exception NSException Thrown if block is nil
 */
- (void)BB_each:(void(^)(id key, id value))block;
/**
 Create and return a new dictionary by enumerating the receiver, invoking block for each key/value pair, and including it in the new dictionary if block returns YES.
 
 @param block The block to invoke for each key/value pair
 @return The new dictionary
 @exception NSException Thrown if block is nil
 */
- (NSDictionary *)BB_filter:(BOOL(^)(id key, id value))block;
/**
 Create and return a new dictionary by enumerating the receiver, invoking block for each key/value pair, and including it in the new dictionary if block returns NO.
 
 @param block The block to invoke for each key/value pair
 @return The new dictionary
 @exception NSException Thrown if block is nil
 */
- (NSDictionary *)BB_reject:(BOOL(^)(id key, id value))block;
/**
 Return the value member of the first key/value pair in the receiver for which block returns YES, or nil if block returns NO for all key/value pairs.
 
 @param block The block to invoke for each key/value pair
 @return The value member of the matching key/value pair
 @exception NSException Thrown if block is nil
 */
- (nullable id)BB_find:(BOOL(^)(id key, id value))block;
/**
 Return a dictionary containing the first key/value pair in the receiver for which block returns YES, or nil if block returns NO for all key/value pairs.
 
 @param block The block to invoke for each key/value pair
 @return The dictionary containing the matching key/value pair, or nil
 @exception NSException Thrown if block is nil
 */
- (nullable NSDictionary *)BB_findWithKey:(BOOL(^)(id key, id value))block;
/**
 Create and return a new dictionary containing all keys from the receiver mapped to new values that block returns. If block returns nil for a key/value pair, [NSNull null] is used as the value in the new dictionary.
 
 @param block The block to invoke for each key/value pair
 @return The dictionary containing new key/value pairs
 @exception NSException Thrown if block is nil
 */
- (NSDictionary *)BB_map:(id _Nullable(^)(id key, id value))block;
/**
 Return a new object that is the result of invoking block for each key/value pair in the receiver, passing the current sum, the key, and value. The return value of one invocation is passed as the sum argument to the next invocation.
 
 @param start The starting value for the reduction
 @param block The block to invoke for each key/value pair
 @return The result of the reduction
 @exception NSException Thrown if block is nil
 */
- (nullable id)BB_reduceWithStart:(nullable id)start block:(id _Nullable(^)(id _Nullable sum, id key, id value))block;
/**
 Returns YES if block returns YES for any key/value pair in the receiver, otherwise NO.
 
 @param block The block to invoke for every key/value pair
 @return YES if block returns YES once, otherwise NO
 @exception NSException Thrown if block is nil
 */
- (BOOL)BB_any:(BOOL(^)(id key, id value))block;
/**
 Returns YES if block returns YES for all key/value pairs in the receiver, otherwise NO.
 
 @param block The block to invoke for every key/value pair
 @return YES if block returns YES for all key/value pairs, otherwise NO
 @exception NSException Thrown if block is nil
 */
- (BOOL)BB_all:(BOOL(^)(id key, id value))block;
/**
 Returns the result of `[self.allValues BB_sum]`.
 
 @return The sum of all values in the receiver
 */
- (id)BB_sum;
/**
 Returns the result of `[self.allValues BB_product]`.
 
 @return The product of all values in the receiver
 */
- (id)BB_product;
/**
 Returns the result of `[self.allValues BB_maximum]`.
 
 @return The maximum of all values in the receiver
 */
- (id)BB_maximum;
/**
 Returns the result of `[self.allValues BB_minimum]`.
 
 @return The minimum of all values in the receiver
 */
- (id)BB_minimum;

@end

NS_ASSUME_NONNULL_END