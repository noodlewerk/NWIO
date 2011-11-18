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
 * NWIOAccess represents fixed-length data that can be read from and written to in any order, similar to NSData.
 *
 * Subclasses should implement at least one read and one write method. If a buffer is NULL, it should be interpret as a transparent constant buffer. If a range or location is out of the access' length, it should be clamped.
 *
 * @warning NB: This is an abstract class. Do not instantiate it directly, but subclass and override abstract methods.
 */
@interface NWIOAccess: NWIOBase

/**
 * The length of the underlying input data. All read ranges should fall within this length.
 * @return The number of input bytes available for reading.
 */
- (NSUInteger)inputLength;

/**
 * The length of the underlying output data. All write ranges should fall within this length.
 * @return The number of output bytes available for writing.
 */
- (NSUInteger)outputLength;

/**
 * Reads bytes into the buffer, starting at `range.location`, over a maximum length `range.length`.
 * @param buffer The buffer into which input bytes will be read.
 * @param range The range of input bytes to read from.
 * @return The number of bytes actually read.
 */
- (NSUInteger)read:(void *)buffer range:(NSRange)range;

/**
 * Provides a buffer with read bytes, and starts at `location` in access.
 * @param buffer The buffer that will be assigned the input bytes read.
 * @param location The byte offset in the input.
 * @return The number of bytes available in `buffer`.
 */
- (NSUInteger)readable:(const void **)buffer location:(NSUInteger)location;

/**
 * Writes bytes from the buffer, starting at `range.location`, over a maximum length `range.length`.
 * @param buffer The buffer from which output bytes will be written.
 * @param range The range of output bytes to write to.
 * @return The number of bytes actually written.
 */
- (NSUInteger)write:(const void *)buffer range:(NSRange)range;

/**
 * Provides a buffer to write into, and starts at `location` in access.
 * @param buffer The buffer that will be assigned the output bytes to write to.
 * @param location The byte offset in the output.
 * @return The number of bytes available in `buffer`.
 */
- (NSUInteger)writable:(void **)buffer location:(NSUInteger)location;

@end
