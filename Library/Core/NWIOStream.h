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
 * An abstract base class for sequential-streaming operations.
 *
 * NWIOStream represents a stream that can be read from and written to, similar to NSInputStream and NSOutputStream
 *
 * Subclasses should implement at least one read and one write method. If a buffer is NULL, it should be interpret as a transparent constant buffer. If a range or location is out of the access' length, it should be clamped.
 *
 * @warning NB: This is an abstract class. Do not instantiate it directly, but subclass and override abstract methods.
 */
@interface NWIOStream : NWIOBase

// TODO: consider renaming to 'bufferLength'
/**
 * The length for the internal buffer used to switch between active (read/write) and passive (readable/writable).
 */
@property (nonatomic, assign) NSUInteger bLength;

/**
 * Reads next input bytes into the buffer.
 * @param buffer The buffer into which input bytes will be read.
 * @param length Buffer length.
 * @return The number of bytes actually read.
 */
- (NSUInteger)read:(void *)buffer length:(NSUInteger)length;

/**
 * Provides a buffer with next input bytes.
 * @param buffer The buffer that will be assigned the input bytes read.
 * @return The number of bytes available in `buffer`.
 */
- (NSUInteger)readable:(const void **)buffer;

/**
 * Writes next output bytes from the buffer.
 * @param buffer The buffer from which output bytes will be written.
 * @param length Buffer length.
 * @return The number of bytes actually written.
 */
- (NSUInteger)write:(const void *)buffer length:(NSUInteger)length;

/**
 * Provides a buffer to write next output bytes into.
 * @param buffer The buffer that will be assigned the output bytes to write to.
 * @return The number of bytes available in `buffer`.
 * @see unwritable:
 */
- (NSUInteger)writable:(void **)buffer;

/**
 * Should be called if not all buffer data from last writable: are used.
 * @param length The number of bytes that were not written to.
 * @see writable:
 */
- (void)unwritable:(NSUInteger)length;

/**
 * Flushes the write buffer used for conversion between write and writable.
 */
- (void)flushStream;

/**
 * Checks whether the input has been fully depleted. NB: Use [hasReadEndedOrFailed:] to decide on performing another read.
 * @return YES if there are more bytes available in the underlying source or buffers.
 * @see hasReadEndedOrFailed:
 * @see [NWIOBase readError]
 */
- (BOOL)hasReadBytesAvailable;

/**
 * Checks whether the output has been saturated. NB: Use [hasWriteEndedOrFailed:] to decide on performing another write.
 * @return YES if there is no more space available in the underlying source or buffers.
 * @see hasWriteEndedOrFailed:
 * @see [NWIOBase writeError]
 */
- (BOOL)hasWriteSpaceAvailable;

/**
 * Moves the reader to the start of the input and sets the internal state as before any read was performed.
 */
- (void)rewindRead;

/**
 * Moves the writer to the start of the output and sets the internal state as before any write was performed.
 */
- (void)rewindWrite;

/**
 * Convenience function to test if we're done reading by combining hasReadBytesAvailable and readError.
 * @param error Contains an error is read ended because of an error.
 * @return YES if there are no more bytes available or an error occurred.
 * @see hasReadBytesAvailable
 * @see [NWIOBase readError]
 */
- (BOOL)hasReadEndedOrFailed:(NSError **)error;

/**
 * Convenience function to test if we're done writing by combining hasWriteSpaceAvailable and writeError.
 * @param error Contains an error is write ended because of an error.
 * @return YES if there is no more space available or an error occurred.
 * @see hasWriteSpaceAvailable
 * @see [NWIOBase writeError]
 */
- (BOOL)hasWriteEndedOrFailed:(NSError **)error;

@end
