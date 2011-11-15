//
//  NWIOProgress.h
//  NWIO
//
//  Copyright 2011 Noodlewerk
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "NWIOFilter.h"

/**
 * An identity filter that counts processed bytes and calls blocks according to progress.
 */
@interface NWIOProgressStream : NWIOFilterStream

/**
 * Keeps track of the total number of bytes streamed
 */
@property (nonatomic, assign, readonly) NSUInteger streamedLength;

/**
 * When set, allows to report progress in ratio
 */
@property (nonatomic, assign) NSUInteger expectedLength;

/**
 * When set, length progress will only report on this byte interval
 */
@property (nonatomic, assign) NSUInteger intervalLength;

/**
 * When set, ratio progress will only report on this ratio interval
 */
@property (nonatomic, assign) double intervalRatio;

/**
 * The queue from which progress blocks are called, init queue by default
 */
@property (nonatomic, strong) NSOperationQueue *blocksQueue;

/**
 * Called with the number of bytes that were streamed
 */
@property (nonatomic, strong) void(^didStreamLengthBlock)(NSUInteger);

/**
 * Called with the current progress ratio
 */
@property (nonatomic, strong) void(^didStreamRatioBlock)(double);

/**
 * Called when the end of the read is reached
 */
@property (nonatomic, strong) void(^didFinishWithLengthBlock)(NSUInteger);

@end
