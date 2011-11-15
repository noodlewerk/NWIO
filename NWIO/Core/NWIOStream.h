//
//  NWIOStream.h
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
 * The one-and-only stream.
 *
 * @warning: This is an abstract class, do not instantiate it directly.
 */
@interface NWIOStream : NWIOBase

// TODO: consider renaming to 'bufferLength'
/**
 * The length for the internal buffer used to switch between active (read/write) and passive (readable/writable).
 */
@property (nonatomic, assign) NSUInteger bLength;

- (NSUInteger)read:(void *)buffer length:(NSUInteger)length;
- (NSUInteger)readable:(const void **)buffer;
- (NSUInteger)write:(const void *)buffer length:(NSUInteger)length;
- (NSUInteger)writable:(void **)buffer;
- (void)unwritable:(NSUInteger)length;

/**
 * Flushes the write buffer used for conversion between write and writable.
 */
- (void)flushStream;

- (BOOL)hasReadBytesAvailable;
- (BOOL)hasWriteSpaceAvailable;
- (void)rewindRead;
- (void)rewindWrite;

/**
 * Convenience funtion to test if we're done reading by combining hasReadBytesAvailable and readError.
 */
- (BOOL)hasReadEnded;

/**
 * Convenience funtion to test if we're done writing by combining hasWriteSpaceAvailable and writeError.
 */
- (BOOL)hasWriteEnded;

@end
