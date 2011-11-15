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
    void *rBuffer;
    NSUInteger rLength;
    BOOL freeRBuffer;
    void *wBuffer;
    NSUInteger wLength;
    NSRange wRange;
    BOOL freeWBuffer;
}

@synthesize bLength;


#pragma mark - Object life cycle

- (void)cleanupRead {
    if (freeRBuffer) {
        // only cleanup buffer if it was allocated by stream
        free(rBuffer);
    }
    rBuffer = NULL;
    rLength = 0;
    freeRBuffer = NO;
}

- (void)cleanupWrite {
    if (freeWBuffer) {
        // only cleanup buffer if it was allocated by stream
        free(wBuffer);
    }
    wBuffer = NULL;
    wLength = 0;
    wRange.length = 0;
    wRange.location = 0;
    freeWBuffer = NO;
}

- (void)dealloc {
    [self cleanupRead];
    [self cleanupWrite];
}

- (void)setBLength:(NSUInteger)_bLength {
    if (!freeRBuffer && !freeWBuffer) {
        // buffers not yet in use, so we can change length
        bLength = _bLength;
    } else {
        NSLog(@"Unable to change bufferLength after first readable or writable");
    }
}


#pragma mark - Default implementation of IO operations

- (NSUInteger)read:(void *)buffer length:(NSUInteger)length {
    NSUInteger result = 0;
    for (BOOL noRead = YES; length && noRead;) {
        if (!rLength) {
            // no leftovers so read from stream
            rLength = [self readable:(const void **)&rBuffer];
            if (!rLength) {
                // apparently nothing available, so stop
                break;
            }
            noRead = NO;
        }
        // copy as much is availble in both 'buffer' and 'readBuffer'
        NSUInteger l = rLength < length ? rLength : length;
        if (buffer && rBuffer && l) {
            memcpy(buffer, rBuffer, l);
        }
        if (buffer) {
            buffer += l;
        }
        length -= l;
        if (rBuffer) {
            rBuffer += l;
        }
        rLength -= l;
        result += l;
    }
    return result;
}

- (NSUInteger)readable:(const void **)buffer {
    if (!rBuffer) {
        // fix configuration
        if (!bLength) {
            bLength = NWIODefaultBufferLength;
        }
        // ensure internal buffer
        rBuffer = malloc(bLength);
        if (!rBuffer) {
            // unable to allocate, exit
            return 0;
        }
        memset(rBuffer, 0, bLength);
        freeRBuffer = YES;
    }
    NSUInteger result = [self read:rBuffer length:bLength];
    if (result > bLength) {
        result = bLength;
    }
    if (buffer) {
        *buffer = rBuffer;
    }
    return result;
}

- (NSUInteger)write:(const void *)buffer length:(NSUInteger)length {
    NSUInteger result = 0;
    for (BOOL noWrite = YES; length && noWrite;) {
        if (!wLength) {
            // no leftovers getspace from stream
            wLength = [self writable:&wBuffer];
            if (!wLength) {
                // apparently no space available, so stop
                break;
            }
            noWrite = NO;
        }
        // copy as much is available in both buffers
        NSUInteger l = wLength < length ? wLength : length;
        if (buffer && wBuffer && l) {
            memcpy(wBuffer, buffer, l);
        }
        if (buffer) {
            buffer += l;
        }
        length -= l;
        if (wBuffer) {
            wBuffer += l;
        }
        wLength -= l;
        result += l;
    }
    return result;
}

- (NSUInteger)writable:(void **)buffer {
    if (!wBuffer) {
        // fix configuration
        if (!bLength) {
            bLength = NWIODefaultBufferLength;
        }
        // ensure internal buffer
        wBuffer = malloc(bLength);
        if (!wBuffer) {
            // unable to allocate, exit
            return 0;
        }
        memset(wBuffer, 0, bLength);
        freeWBuffer = YES;
    } else if (wRange.length) {
        // flush last writable first
        NSUInteger l = [self write:wBuffer + wRange.location length:wRange.length];
        if (l < wRange.length) {
            // there are still writes to be done, keep for next invocation
            wRange.location += l;
            wRange.length -= l;
            return 0;
        }
    }
    if (buffer) {
        *buffer = wBuffer;
    }
    // plan writes for next invocation
    wRange = NSMakeRange(0, bLength);
    return bLength;
}

- (void)unwritable:(NSUInteger)length {
    if (length < wRange.length) {
        wRange.length -= length;
    } else {
        wRange.length = 0;
    }
}


#pragma mark - Stream helpers

- (void)flushStream {
    if (wLength) {
        // we have some writable space that won't be used anymore
        [self unwritable:wLength];
    }
    while (wRange.length) {
        // flush last writable
        NSUInteger l = [self write:wBuffer + wRange.location length:wRange.length];
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
    return rLength > 0;
}

- (BOOL)hasWriteSpaceAvailable {
    // if 'wBuffer' still contains bytes
    return wLength > 0;
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

- (BOOL)hasReadEnded {
    if (![self hasReadBytesAvailable]) {
        return YES;
    }
    NSError *error = [self readError];
    if (error) {
        NSAssert(NO, @"Error in read: %@", error);
        return YES;
    }
    return NO;
}

- (BOOL)hasWriteEnded {
    if (![self hasWriteSpaceAvailable]) {
        return YES;
    }
    NSError *error = [self writeError];
    if (error) {
        NSAssert(NO, @"Error in write: %@", error);
        return YES;
    }
    return NO;
}

@end
