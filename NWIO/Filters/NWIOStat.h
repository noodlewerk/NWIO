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

#import "NWIOFilter.h"


/**
 * A container for statistics on a single variable.
 */
@interface NWIOStatInteger : NSObject
@property (nonatomic, assign, readonly) long int count;
@property (nonatomic, assign, readonly) NSUInteger average;
@property (nonatomic, assign, readonly) long long int variance;
@property (nonatomic, assign, readonly) NSUInteger deviation;
- (void)count:(NSUInteger)value;
- (void)uncount:(NSUInteger)value;
@end


/**
 * Records statistics of data passing though this filter, without modifiying it.
 */
@interface NWIOStatStream : NWIOFilterStream
@property (nonatomic, strong, readonly) NWIOStatInteger *lengthStat;
@end


/**
 * Records statistics of data passing though this filter, without modifiying it.
 */
@interface NWIOStatAccess : NWIOFilterAccess
@property (nonatomic, strong, readonly) NWIOStatInteger *locationStat;
@property (nonatomic, strong, readonly) NWIOStatInteger *lengthStat;
@end