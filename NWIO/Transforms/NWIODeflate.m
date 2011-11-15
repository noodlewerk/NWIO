//
//  NWIODeflate.m
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

#import "NWIODeflate.h"
#include <zlib.h>

static NSString * const NWIOStatusKey = @"status";
static NSString * const NWIOMessageKey = @"message";

@implementation NWIODeflateTransform {
    z_stream *backwardStream;
    z_stream *forwardStream;
    void *transparentBuffer;
}

@synthesize transparentBufferLength;


#pragma mark - Object life cycle

// TODO: add initializer with deflation level

- (void)dealloc {
    [self resetBackward];
    [self resetForward];
}

- (void)setTransparentBufferLength:(NSUInteger)_transparentBufferLength {
    if (!transparentBuffer) {
        // buffer not yet in use, so we can change length
        transparentBufferLength = _transparentBufferLength;
    } else {
        NSLog(@"Unable to change bufferLength after first transform operation");
    }
}

#pragma mark - Error handling

- (NSError *)errorForStatus:(int)status message:(const char *)message {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInteger:status] forKey:NWIOStatusKey];
    if (message) {
        NSString *m = [NSString stringWithCString:message encoding:NSUTF8StringEncoding];
        [info setObject:m forKey:NWIOMessageKey];
    }
    NSError *result = [NSError errorWithDomain:NSStringFromClass(self.class) code:status userInfo:info];
    return result;
}


#pragma mark - NWIOTransform subclass

// TODO: add support for transparent (NULL) buffers

// turns zip into bytes (inflate)
- (BOOL)transformBackwardFromBuffer:(const unsigned char *)fromBuffer fromLength:(NSUInteger)fromLength fromInc:(NSUInteger *)fromInc toBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    NSAssert(fromBuffer, @"Can't inflate transparent bytes");
    if (!toBuffer) {
        // output is transparent, so use substitute
        if (!transparentBuffer) {
            if (!transparentBufferLength) {
                transparentBufferLength = NWIODefaultBufferLength;
            }
            transparentBuffer = malloc(transparentBufferLength);
            memset(transparentBuffer, 0, transparentBufferLength);
        }
        toBuffer = transparentBuffer;
        if (toLength > transparentBufferLength) {
            toLength = transparentBufferLength;
        }
    }
    if (!backwardStream) {
        backwardStream = malloc(sizeof(z_stream));
        memset(backwardStream, 0, sizeof(z_stream));
        int status = inflateInit(backwardStream);
        if (status < 0) {
            if (error) {
                *error = [self errorForStatus:status message:backwardStream->msg];
            }
            free(backwardStream); backwardStream = NULL;
            return NO;
        }
    }
    backwardStream->next_in = (unsigned char *)fromBuffer;
    backwardStream->avail_in = fromLength;
    backwardStream->next_out = toBuffer;
    backwardStream->avail_out = toLength;
    int status = inflate(backwardStream, Z_NO_FLUSH);
    if (status < 0) {
        if (error) {
            *error = [self errorForStatus:status message:backwardStream->msg];
        }
        return NO;
    }
    *fromInc = backwardStream->next_in - fromBuffer;
    *toInc = backwardStream->next_out - toBuffer;
    return YES;
}

// turns bytes into zip (deflate)
- (BOOL)transformForwardFromBuffer:(const unsigned char *)fromBuffer fromLength:(NSUInteger)fromLength fromInc:(NSUInteger *)fromInc toBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    NSAssert(fromBuffer, @"Can't deflate transparent bytes");
    if (!toBuffer) {
        // output is transparent, so use substitute
        if (!transparentBuffer) {
            if (!transparentBufferLength) {
                transparentBufferLength = NWIODefaultBufferLength;
            }
            transparentBuffer = malloc(transparentBufferLength);
            memset(transparentBuffer, 0, transparentBufferLength);
        }
        toBuffer = transparentBuffer;
        if (toLength > transparentBufferLength) {
            toLength = transparentBufferLength;
        }
    }
    if (!forwardStream) {
        forwardStream = malloc(sizeof(z_stream));
        memset(forwardStream, 0, sizeof(z_stream));
        int status = deflateInit(forwardStream, Z_DEFAULT_COMPRESSION);
        if (status < 0) {
            if (error) {
                *error = [self errorForStatus:status message:forwardStream->msg];
            }
            free(forwardStream); forwardStream = NULL;
            return NO;
        }
    }
    forwardStream->next_in = (unsigned char *)fromBuffer;
    forwardStream->avail_in = fromLength;
    forwardStream->next_out = toBuffer;
    forwardStream->avail_out = toLength;
    int status = deflate(forwardStream, Z_NO_FLUSH);
    if (status < 0) {
        if (error) {
            *error = [self errorForStatus:status message:forwardStream->msg];
        }
        return NO;
    }
    *fromInc = forwardStream->next_in - fromBuffer;
    *toInc = forwardStream->next_out - toBuffer;
    return YES;
}

- (BOOL)flushBackwardToBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    if (!backwardStream) {
        *toInc = 0;
        return YES;
    }
    backwardStream->next_out = toBuffer;
    backwardStream->avail_out = toLength;
    int status = inflate(backwardStream, Z_FINISH);
    if (status < 0) {
        if (error) {
            *error = [self errorForStatus:status message:backwardStream->msg];
        }
        return NO;
    }
    *toInc = backwardStream->next_out - toBuffer;
    NSAssert(*toInc != 0 || status == Z_STREAM_END, @"no bytes should be equivalent to steam end");
    return YES;
}

- (BOOL)flushForwardToBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    if (!forwardStream) {
        *toInc = 0;
        return YES;
    }
    forwardStream->next_out = toBuffer;
    forwardStream->avail_out = toLength;
    int status = deflate(forwardStream, Z_FINISH);
    if (status < 0) {
        if (error) {
            *error = [self errorForStatus:status message:forwardStream->msg];
        }
        return NO;
    }
    *toInc = forwardStream->next_out - toBuffer;
    NSAssert(*toInc != 0 || status == Z_STREAM_END, @"no bytes should be equivalent to steam end");
    return YES;
}

- (void)resetBackward {
    if (backwardStream) {
        inflateEnd(backwardStream);
        free(backwardStream); backwardStream = NULL;
    }
}

- (void)resetForward {
    if (forwardStream) {
        deflateEnd(forwardStream);
        free(forwardStream); forwardStream = NULL;
    }
}

@end



@implementation NWIODeflateStream

- (id)initWithStream:(NWIOStream *)_stream {
    return [super initWithStream:_stream transform:[[NWIODeflateTransform alloc] init]];
}

@end
