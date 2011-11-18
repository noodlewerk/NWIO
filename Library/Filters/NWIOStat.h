//
//  NWIOStat.h
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

#import "NWIOIdentity.h"


/**
 * A container for statistics on a single series of values.
 */
@interface NWIOStatInteger : NSObject

/**
 * The sum of all values.
 */
@property (nonatomic, assign, readonly) long int count;

/**
 * The average of values (count / N).
 */
@property (nonatomic, assign, readonly) NSUInteger average;

/**
 * The variance of values (sum-square-diffs / N).
 */
@property (nonatomic, assign, readonly) long long int variance;

/**
 * The deviation of values (sqrt(variance)).
 */
@property (nonatomic, assign, readonly) NSUInteger deviation;

/**
 * Registers next value.
 */
- (void)count:(NSUInteger)value;

/**
 * Undoes registration of value, approximately.
 */
- (void)uncount:(NSUInteger)value;

@end


/**
 * Records statistics of data passing though this filter.
 */
@interface NWIOStatStream : NWIOIdentityStream

/**
 * Statistics on the length of the read and write buffers.
 */
@property (nonatomic, strong, readonly) NWIOStatInteger *lengthStat;

@end


/**
 * Records statistics of data passing though this filter.
 */
@interface NWIOStatAccess : NWIOIdentityAccess

/**
 * Statistics on the offset of the read and write buffers.
 */
@property (nonatomic, strong, readonly) NWIOStatInteger *locationStat;

/**
 * Statistics on the length of the read and write buffers.
 */
@property (nonatomic, strong, readonly) NWIOStatInteger *lengthStat;

@end
