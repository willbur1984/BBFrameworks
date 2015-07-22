//
//  NSArray+BBBlocksExtensions.h
//  BBFrameworks
//
//  Created by William Towe on 7/22/15.
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

/**
 Predicate block returning a boolean and taking an object and index.
 
 @param object The object in the array
 @param index The index of object in the array
 @return YES or NO if the object passes predicate
 */
typedef BOOL(^BBBlockPredicateObjectAndIndexBlock)(id object, NSInteger index);
/**
 Block returning a new object given an object and index.
 
 @param object The object in the array
 @param index The index of object in the array
 @return The new object
 */
typedef id(^BBBlockObjectAndIndexBlock)(id object, NSInteger index);
/**
 Block returning the new sum given object and index.
 
 @param sum The current sum of the reduction
 @param object The object in the array
 @param index The index of object in the array
 @return The new sum
 */
typedef id(^BBBlockSumObjectAndIndexBlock)(id sum, id object, NSInteger index);

/**
 Category on NSArray adding block extensions.
 */
@interface NSArray (BBBlocksExtensions)

/**
 Create and return a new array by enumerating the receiver, invoking block for each object, and including it in the new array if block returns YES.
 
 @param block The block to invoke for each object in the receiver
 @return The new array
 @exception NSException Thrown if block is nil
 */
- (NSArray *)BB_filter:(BBBlockPredicateObjectAndIndexBlock)block;
/**
 Return the first object in the receiver for which block returns YES, or nil if block returns NO for all objects in the receiver.
 
 @param block The block to invoke for each object in the receiver
 @return The matching object or nil
 @exception NSException Thrown if block is nil
 */
- (id)BB_find:(BBBlockPredicateObjectAndIndexBlock)block;
/**
 Return an array of the first object in the receiver along with its index for which block returns YES, or nil if block returns NO for all objects in the receiver.
 
 @param block The block to invoke for each object in the receiver
 @return An array where the first object is an object in the receiver and second object is the index of the object in the receiver, or nil
 @exception NSException Thrown if block is nil
 */
- (NSArray *)BB_findWithIndex:(BBBlockPredicateObjectAndIndexBlock)block;
/**
 Create and return a new array by enumerating the receiver, invoking block for each object, and including the return value of block in the new array.
 
 @param block The block to invoke for each object in the receiver
 @return The new array
 */
- (NSArray *)BB_map:(BBBlockObjectAndIndexBlock)block;
/**
 Return a new object that is the result of enumerating the receiver and invoking block, passing the current sum, the object, and the index of object in the receiver. The return value of block is passed in as sum to the next invocation of block.
 
 @param start The starting value for the reduction
 @param block The block to invoke for each object in the receiver
 @return The result of the reduction
 @exception NSException Thrown if block is nil
 */
- (id)BB_reduceWithStart:(id)start block:(BBBlockSumObjectAndIndexBlock)block;
/**
 Return YES if block returns YES for any object in the receiver, otherwise NO.
 
 @param block The block to invoke for each object in the receiver
 @return YES if block returns YES for any object, otherwise NO
 @exception NSException Thrown if block is nil
 */
- (BOOL)BB_any:(BBBlockPredicateObjectAndIndexBlock)block;
/**
 Return YES if block returns YES for all objects in the receiver, otherwise NO.
 
 @param block The block to invoke for each object in the receiver
 @return YES if block returns YEs for all objects, otherwise NO
 @exception NSException Throw if block is nil
 */
- (BOOL)BB_all:(BBBlockPredicateObjectAndIndexBlock)block;

@end
