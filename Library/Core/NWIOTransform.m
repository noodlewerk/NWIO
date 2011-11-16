//
//  NWIOTransform.m
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

#import "NWIOTransform.h"


@implementation NWIOTransform


#pragma mark - Transform abstract

- (BOOL)transformBackwardFromBuffer:(const unsigned char *)fromBuffer fromLength:(NSUInteger)fromLength fromInc:(NSUInteger *)fromInc toBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    NSAssert(NO, @"transformBackwardFromBuffer not supported");
    return YES;
}

- (BOOL)transformForwardFromBuffer:(const unsigned char *)fromBuffer fromLength:(NSUInteger)fromLength fromInc:(NSUInteger *)fromInc toBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    NSAssert(NO, @"transformForwardFromBuffer not supported");
    return YES;
}

- (BOOL)flushBackwardToBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    NSAssert(NO, @"flushBackwardToBuffer not supported");
    return YES;
}

- (BOOL)flushForwardToBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    NSAssert(NO, @"flushForwardToBuffer not supported");
    return YES;
}

- (void)resetBackward {
    NSAssert(NO, @"resetBackward not supported");
}

- (void)resetForward {
    NSAssert(NO, @"resetForward not supported");
}

@end


@implementation NWIOTransformStream {
    const void *readBuffer;
    NSUInteger readLength;
    BOOL isReadFlushed;
    NSError *readError;

    void *writeBuffer;
    NSUInteger writeLength;
    BOOL isWriteFlushed;
    NSError *writeError;
}

@synthesize transform, inverted;

#pragma mark - Object life cycle

- (id)initWithStream:(NWIOStream *)_stream transform:(NWIOTransform *)_transform inverted:(BOOL)_inverted {
    self = [super initWithStream:_stream];
    if (self) {
        transform = _transform;
        inverted = _inverted;
    }
    return self;
}

- (id)initWithStream:(NWIOStream *)_stream transform:(NWIOTransform *)_transform {
    return [self initWithStream:_stream transform:_transform inverted:NO];
}

- (id)initWithTransform:(NWIOTransform *)_transform {
    return [self initWithStream:nil transform:_transform inverted:NO];
}

- (void)cleanupRead {
    readBuffer = NULL;
    readLength = 0;
    isReadFlushed = NO;
    readError = nil;
}

- (void)cleanupWrite {
    writeBuffer = NULL;
    writeLength = 0;
    isWriteFlushed = NO;
    writeError = nil;
}

- (void)invert {
    inverted = YES;
}

#pragma mark - Transform helpers

- (NSUInteger)readToBuffer:(void **)toBuffer toLength:(NSUInteger *)toLength {
    NSUInteger fromInc = 0, toInc = 0;
    NSError *error = nil;
    NSAssert(transform, @"No transform set");
    if (inverted) {
        [transform transformForwardFromBuffer:readBuffer fromLength:readLength fromInc:&fromInc toBuffer:*toBuffer toLength:*toLength toInc:&toInc error:&error];
    } else {
        [transform transformBackwardFromBuffer:readBuffer fromLength:readLength fromInc:&fromInc toBuffer:*toBuffer toLength:*toLength toInc:&toInc error:&error];
    }
    readError = error;
    // make sure we don't to-of-bounds
    if (fromInc > readLength) fromInc = readLength;
    if (toInc > *toLength) toInc = *toLength;
    // update state of buffers
    if (readBuffer) readBuffer += fromInc;
    if (*toBuffer) *toBuffer += toInc;
    // update state of lengths
    readLength -= fromInc;
    *toLength -= toInc;
    return toInc;
}

- (NSUInteger)writeFromBuffer:(const void **)fromBuffer fromLength:(NSUInteger *)fromLength {
    NSUInteger fromInc = 0, toInc = 0;
    NSError *error = nil;
    NSAssert(transform, @"No transform set");
    if (inverted) {
        [transform transformBackwardFromBuffer:*fromBuffer fromLength:*fromLength fromInc:&fromInc toBuffer:writeBuffer toLength:writeLength toInc:&toInc error:&error];
    } else {
        [transform transformForwardFromBuffer:*fromBuffer fromLength:*fromLength fromInc:&fromInc toBuffer:writeBuffer toLength:writeLength toInc:&toInc error:&error];
    }
    writeError = error;
    // make sure we don't to-of-bounds
    if (fromInc > *fromLength) fromInc = *fromLength;
    if (toInc > writeLength) toInc = writeLength;
    // update state of buffers
    if (*fromBuffer) *fromBuffer += fromInc;
    if (writeBuffer) writeBuffer += toInc;
    // update state of lengths
    *fromLength -= fromInc;
    writeLength -= toInc;
    return fromInc;
}

- (NSUInteger)flushReadToBuffer:(void **)toBuffer toLength:(NSUInteger *)toLength {
    NSUInteger toInc = 0;
    NSError *error = nil;
    if (inverted) {
        [transform flushForwardToBuffer:*toBuffer toLength:*toLength toInc:&toInc error:&error];
    } else {
        [transform flushBackwardToBuffer:*toBuffer toLength:*toLength toInc:&toInc error:&error];
    }
    if (toLength > 0 && toInc == 0) {
        isReadFlushed = YES;
    }
    readError = error;
    // make sure we don't to-of-bounds
    if (toInc > *toLength) toInc = *toLength;
    // update state of buffers
    if (*toBuffer) *toBuffer += toInc;
    // update state of lengths
    *toLength -= toInc;
    return toInc;
}

- (NSUInteger)flushWrite {
    NSUInteger toInc = 0;
    NSError *error = nil;
    if (inverted) {
        [transform flushBackwardToBuffer:writeBuffer toLength:writeLength toInc:&toInc error:&error];
    } else {
        [transform flushForwardToBuffer:writeBuffer toLength:writeLength toInc:&toInc error:&error];
    }
    if (writeLength > 0 && toInc == 0) {
        isWriteFlushed = YES;
    }
    writeError = error;
    // make sure we don't to-of-bounds
    if (toInc > writeLength) toInc = writeLength;
    // update state of buffers
    if (writeBuffer) writeBuffer += toInc;
    // update state of lengths
    writeLength -= toInc;
    return toInc;
}


#pragma mark - NWIOStream subclass

- (NSUInteger)read:(void *)buffer length:(NSUInteger)length {
    NSUInteger result = 0;
    if (readLength) {
        // there are some leftovers, to be processed first
        result += [self readToBuffer:&buffer toLength:&length];
        if (readLength) {
            // unable to fully process leftovers, we're full, return
            return result;
        }
    }
    // 'readLength' is now zero, time to get some new space
    readLength = [stream readable:&readBuffer];
    if (readLength) {
        // new bytes available, transform
        result += [self readToBuffer:&buffer toLength:&length];
        return result;
    }
    // apparently nothing available atm
    if (![stream hasReadBytesAvailable] && !isReadFlushed) {
        // no data will become available, so flush the transform
        result += [self flushReadToBuffer:&buffer toLength:&length];
        return result;
    }
    return result;
}

- (NSUInteger)write:(const void *)buffer length:(NSUInteger)length {
    NSUInteger result = 0;
    if (writeLength) {
        // there is some leftover space to fill first
        result += [self writeFromBuffer:&buffer fromLength:&length];
        if (writeLength) {
            // did not fully fill leftover space, so we can't continue streaming new
            return result;
        }
    }
    // 'writeLength' is now zero, time to write
    writeLength = [stream writable:&writeBuffer];
    if (writeLength) {
        // new space available, transform
        result += [self writeFromBuffer:&buffer fromLength:&length];
        return result;
    }
    // apparently no space available, so stop
    return result;
}

- (void)flushTransform {
    while (!isWriteFlushed) {
        while (!writeLength) {
            // 'writeLength' is zero, time for a new buffer
            writeLength = [stream writable:&writeBuffer];
        }
        [self flushWrite];
    }
    if (writeLength) {
        // we took a bit too much writable, so unwritable that
        [stream unwritable:writeLength];
    }
}

#pragma mark - Controls

- (BOOL)hasReadBytesAvailable {
    if (readLength) {
        // still leftovers to process
        return YES;
    }
    if (!isReadFlushed) {
        // still leftovers in transform
        return YES;
    }
    return [super hasReadBytesAvailable];
}

- (BOOL)hasWriteBytesAvailable {
    if (readLength) {
        // still leftovers to process
        return YES;
    }
    if (!isReadFlushed) {
        // still leftovers in transform
        return YES;
    }
    return [super hasReadBytesAvailable];
}

- (void)rewindRead {
    [super rewindRead];
    if (inverted) {
        [transform resetForward];
    } else {
        [transform resetBackward];
    }
    [self cleanupRead];
}

- (void)rewindWrite {
    [super rewindWrite];
    if (inverted) {
        [transform resetBackward];
    } else {
        [transform resetForward];
    }
    [self cleanupWrite];
}

- (void)closeRead {
    // nothing to do
    [super closeRead];
}

- (void)closeWrite {
    [self flushStream];
    [self flushTransform];
    [super closeWrite];
}

- (NSError *)readError {
    if (readError) {
        return readError;
    }
    return [super readError];
}

- (NSError *)writeError {
    if (writeError) {
        return writeError;
    }
    return [super writeError];
}

@end