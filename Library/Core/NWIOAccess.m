//
//  NWIOAccess.m
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

#import "NWIOAccess.h"


@implementation NWIOAccess {
    // readable
    void *readableBuffer;
    NSUInteger readableBufferLength;
    // writable
    void *writableBuffer;
    NSUInteger writableBufferLength;
    NSUInteger writableOffset;
    NSRange writableRange;
}

@synthesize bufferLength;


#pragma mark - Object life cycle

- (void)cleanupRead {
    if (readableBuffer) {
        free(readableBuffer);
    }
    readableBuffer = NULL;
    readableBufferLength = 0;
}

- (void)cleanupWrite {
    if (writableBuffer) {
        free(writableBuffer);
    }
    writableBuffer = NULL;
    writableBufferLength = 0;
    writableOffset = 0;
    writableRange.location = 0;
    writableRange.length = 0;
}

- (void)dealloc {
    [self cleanupRead];
    [self cleanupWrite];
}

- (NSUInteger)inputLength {
    NSAssert(NO, @"inputLength not supported");
    return 0;
}

- (NSUInteger)outputLength {
    NSAssert(NO, @"outputLength not supported");
    return 0;
}

#pragma mark - Operations

- (NSUInteger)read:(void *)buffer range:(NSRange)range {
    const void *b = nil;
    NSUInteger r = [self readable:&b location:range.location];
    NSUInteger result = r < range.length ? r : range.length;
    if (buffer && result) {
        if (b) {
            memcpy(buffer, b, result);
        } else {
            memset(buffer, 0, result);
        }
    }
    return result;
}

- (NSUInteger)readable:(const void **)buffer location:(NSUInteger)location {
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
    NSUInteger result = [self read:readableBuffer range:NSMakeRange(location, readableBufferLength)];
    if (result > readableBufferLength) {
        result = readableBufferLength;
    }
    if (buffer) {
        *buffer = readableBuffer;
    }
    return result;
}

- (NSUInteger)write:(const void *)buffer range:(NSRange)range {
    void *b = nil;
    NSUInteger r = [self writable:&b location:range.location];
    NSUInteger result = r < range.length ? r : range.length;
    if (b && result) {
        if (buffer) {
            memcpy(b, buffer, result);
        } else {
            memset(b, 0, result);
        }
    }
    if (result < r) {
        // reclaim writable space we didn't use
        [self unwritable:r - result];
    }
    return result;
}

- (NSUInteger)writable:(void **)buffer location:(NSUInteger)location {
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
    } else if (writableRange.length) {
        // flush last writable first
        NSUInteger l = [self write:writableBuffer + writableOffset range:writableRange];
        if (l < writableRange.length) {
            // there are still writes to be done, keep for next invocation
            writableOffset += l;
            writableRange.location += l;
            writableRange.length -= l;
            return 0;
        }
    }
    if (buffer) {
        *buffer = writableBuffer;
    }
    // plan writes for next invocation
    writableOffset = 0;
    writableRange = NSMakeRange(location, writableBufferLength);
    // clamp to outputLength
    NSUInteger outputLength = self.outputLength;
    if (location > outputLength) {
        writableRange.length = 0;
    } else if (location + writableRange.length > outputLength) {
        writableRange.length = outputLength - location;
    }
    return writableRange.length;
}

- (void)unwritable:(NSUInteger)length {
    if (length < writableRange.length) {
        writableRange.length -= length;
    } else {
        NSAssert(length == writableRange.length, @"Unable to unwrite length %i", length);
        writableRange.length = 0;
    }
}

@end
