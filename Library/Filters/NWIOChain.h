//
//  NWIOChain.h
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
 * Combines a chain of filter streams into a single filter.
 *
 * :c - self (chain)
 * :s - self.stream
 * :f - self.first
 *
 * - chain initWithStream:A
 *
 *          +---+
 *          |:c |   +-----+
 *          |   |==>| A:s |
 *          |   |   +-----+
 *          +---+
 *
 * - chain addFilter:B
 *
 *          +-----------+
 *          |:c +------+|  +---+
 *          |==>| B:sf |==>| A |
 *          |   +------+|  +---+
 *          +-----------+
 *
 * - chain addFilter:C
 *
 *          +--------------------+
 *          |:c +-----+   +-----+|  +---+
 *          |==>| C:s |==>| B:f |==>| A |
 *          |   +-----+   +-----+|  +---+
 *          +--------------------+
 *
 * - D initWithStream:chain
 *
 *          +--------------------+
 *  +---+   |:c +-----+   +-----+|  +---+
 *  | D |==>|==>| C:s |==>| B:f |==>| A |
 *  +---+   |   +-----+   +-----+|  +---+
 *          +--------------------+
 *
 * @see NWIOFilterStream
 */
@interface NWIOChainStream : NWIOIdentityStream

/**
 * Adds a new filter to the chain. The chain will read from this filter, which in turn will read from this chain's stream.
 * @param filter -
 */
- (void)addFilter:(NWIOFilterStream *)filter;

@end


/**
 * Combines a chain of filter accesses into a single filter.
 */
@interface NWIOChainAccess : NWIOIdentityAccess

/**
 * Adds a new filter to the chain. The chain will read from this filter, which in turn will read from this chain's access.
 * @param filter -
 */
- (void)addFilter:(NWIOFilterAccess *)filter;

@end
