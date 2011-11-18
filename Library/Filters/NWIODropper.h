//
//  NWIODropper.h
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
 * Limits operation buffer length by letting only a limited number of bytes though.
 *
 * The dropper is mostly used for testing a streams performance for a certain buffer length.
 */
@interface NWIODropperStream : NWIOFilterStream

/**
 * The maximum length of a buffers that are returned with all read and write operations.
 */
@property (nonatomic, assign) NSUInteger dropSize;

/**
 * Assigns properties and forwards to super.
 * @param stream -
 * @param dropSize -
 */
- (id)initWithStream:(NWIOStream *)stream dropSize:(NSUInteger)dropSize;

@end
