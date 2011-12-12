//
//  NWIOStream.m
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

#import "NWIOStream.h"


@implementation NWIOStream {
    // read
    void *readBuffer;
    NSUInteger readBufferLength;
    // readable
    void *readableBuffer;
    NSUInteger readableBufferLength;
    // write
    void *writeBuffer;
    NSUInteger writeBufferLength;
    // writable
    void *writableBuffer;
    NSUInteger writableBufferLength;
    NSRange wRange;
}

@synthesize bufferLength;


#pragma mark - Object life cycle

- (void)cleanupRead {
    if (readableBuffer) {
        // only cleanup buffer if it was allocated by stream
        free(readableBuffer);
    }
    readBuffer = NULL;
    readBufferLength = 0;
    readableBuffer = NULL;
    readableBufferLength = 0;
}

- (void)cleanupWrite {
    if (writableBuffer) {
        free(writableBuffer);
    }
    writeBuffer = NULL;
    writeBufferLength = 0;
    writableBuffer = NULL;
    writableBufferLength = 0;
    wRange.length = 0;
    wRange.location = 0;
}

- (void)dealloc {
    [self cleanupRead];
    [self cleanupWrite];
}


#pragma mark - Default implementation of IO operations

- (NSUInteger)read:(void *)buffer length:(NSUInteger)length {
    NSUInteger result = 0;
    for (BOOL noRead = YES; length && noRead;) {
        if (!readBufferLength) {
            // no leftovers so read from stream
            readBufferLength = [self readable:(const void **)&readBuffer];
            if (!readBufferLength) {
                // apparently nothing available, so stop
                break;
            }
            noRead = NO;
        }
        // copy as much is availble in both 'buffer' and 'readBuffer'
        NSUInteger l = readBufferLength < length ? readBufferLength : length;
        if (buffer && l) {
            if (readBuffer) {
                memcpy(buffer, readBuffer, l);
            } else {
                memset(buffer, 0, l);
            }
        }
        if (buffer) {
            buffer += l;
        }
        length -= l;
        if (readBuffer) {
            readBuffer += l;
        }
        readBufferLength -= l;
        result += l;
    }
    return result;
}

- (NSUInteger)readable:(const void **)buffer {
    if (!readableBuffer) {
        // fix configuration
        if (bufferLength) {
            readableBufferLength = bufferLength;
        } else {
            readableBufferLength = NWIODefaultBufferLength;
        }
        // ensure internal buffer
        readableBuffer = malloc(readableBufferLength);
        if (!readableBuffer) {
            // unable to allocate, exit
            return 0;
        }
        memset(readableBuffer, 0, readableBufferLength);
    }
    NSUInteger result = [self read:readableBuffer length:readableBufferLength];
    if (result > readableBufferLength) {
        result = readableBufferLength;
    }
    if (buffer) {
        *buffer = readableBuffer;
    }
    return result;
}

- (NSUInteger)write:(const void *)buffer length:(NSUInteger)length {
    NSUInteger result = 0;
    for (BOOL noWrite = YES; length && noWrite;) {
        if (!writeBufferLength) {
            // no leftovers getspace from stream
            writeBufferLength = [self writable:&writeBuffer];
            if (!writeBufferLength) {
                // apparently no space available, so stop
                break;
            }
            noWrite = NO;
        }
        // copy as much is available in both buffers
        NSUInteger l = writeBufferLength < length ? writeBufferLength : length;
        if (writeBuffer && l) {
            if (buffer) {
                memcpy(writeBuffer, buffer, l);
            } else {
                memset(writeBuffer, 0, l);
            }
        }
        if (buffer) {
            buffer += l;
        }
        length -= l;
        if (writeBuffer) {
            writeBuffer += l;
        }
        writeBufferLength -= l;
        result += l;
    }
    return result;
}

- (NSUInteger)writable:(void **)buffer {
    if (!writableBuffer) {
        // fix configuration
        if (bufferLength) {
            writableBufferLength = bufferLength;
        } else {
            writableBufferLength = NWIODefaultBufferLength;
        }
        // ensure internal buffer
        writableBuffer = malloc(writableBufferLength);
        if (!writableBuffer) {
            // unable to allocate, exit
            return 0;
        }
        memset(writableBuffer, 0, writableBufferLength);
    } else if (wRange.length) {
        // flush last writable first
        NSUInteger l = [self write:writableBuffer + wRange.location length:wRange.length];
        if (l < wRange.length) {
            // there are still writes to be done, keep for next invocation
            wRange.location += l;
            wRange.length -= l;
            return 0;
        }
    }
    if (buffer) {
        *buffer = writableBuffer;
    }
    // plan writes for next invocation
    wRange = NSMakeRange(0, writableBufferLength);
    return writableBufferLength;
}

- (void)unwritable:(NSUInteger)length {
    if (length < wRange.length) {
        wRange.length -= length;
    } else {
        NSAssert(length == wRange.length, @"Unable to unwrite length %i", length);
        wRange.length = 0;
    }
}


#pragma mark - Stream helpers

- (void)flushStream {
    if (writableBufferLength) {
        // we have some writable space that won't be used anymore
        [self unwritable:writableBufferLength];
    }
    while (wRange.length) {
        // flush last writable
        NSUInteger l = [self write:writableBuffer + wRange.location length:wRange.length];
        if (l > wRange.length) {
            l = wRange.length;
        }
        wRange.location += l;
        wRange.length -= l;
    }
}


#pragma mark - Controls

- (BOOL)hasReadBytesAvailable {
    // if 'rBuffer' still contains bytes
    return readBufferLength > 0;
}

- (BOOL)hasWriteSpaceAvailable {
    // if 'wBuffer' still contains bytes
    return writeBufferLength > 0;
}

- (void)rewindRead {
    // super doesn't know
    [self cleanupRead];
}

- (void)rewindWrite {
    // super doesn't know
    [self cleanupWrite];
}

- (void)closeRead {
    // nothing to do
}

- (void)closeWrite {
    // throw out remaining bytes before we close
    [self flushStream];
}

#pragma mark - Controls convenience

- (BOOL)hasReadEndedOrFailed:(NSError **)error {
    if (![self hasReadBytesAvailable]) {
        if (error) {
            *error = nil;
        }
        return YES;
    }
    NSError *e = [self readError];
    if (e) {
        if (error) {
            *error = e;
        }
        return YES;
    }
    return NO;
}

- (BOOL)hasWriteEndedOrFailed:(NSError **)error {
    if (![self hasWriteSpaceAvailable]) {
        if (error) {
            *error = nil;
        }
        return YES;
    }
    NSError *e = [self writeError];
    if (e) {
        if (error) {
            *error = e;
        }
        return YES;
    }
    return NO;

}

@end
