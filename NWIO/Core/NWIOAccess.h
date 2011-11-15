//
//  NWIOAccess.h
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

#import "NWIOBase.h"


/**
 * An abstract base class for direct-access operations.
 *
 * @warning: This is an abstract class, do not instantiate it directly.
 */
@interface NWIOAccess: NWIOBase

/**
 * The number of bytes available for reading.
 */
- (NSUInteger)inputLength;

/**
 * The number of bytes available for writing.
 */
- (NSUInteger)outputLength;

/**
 * Reads bytes into the buffer, starting at `range.location`, over a maximum length `range.length`.
 * @returns The number of bytes actually read.
 */
- (NSUInteger)read:(void *)buffer range:(NSRange)range;

/**
 * Provides a buffer with read bytes, and starts at `location` in access.
 * @returns The number of bytes available in `buffer`.
 */
- (NSUInteger)readable:(const void **)buffer location:(NSUInteger)location;

/**
 * Writes bytes from the buffer, starting at `range.location`, over a maximum length `range.length`.
 * @returns The number of bytes actually written.
 */
- (NSUInteger)write:(const void *)buffer range:(NSRange)range;

/**
 * Provides a buffer to write into, and starts at `location` in access.
 * @returns The number of bytes available in `buffer`.
 */
- (NSUInteger)writable:(void **)buffer location:(NSUInteger)location;

@end