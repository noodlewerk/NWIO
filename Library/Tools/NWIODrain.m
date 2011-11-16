//
//  NWIODrain.m
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

#import "NWIODrain.h"


@implementation NWIODrain

@synthesize source, sink, buffered, bufferLength;


#pragma mark - Object life cycle

- (id)initWithSource:(NWIOStream *)_source sink:(NWIOStream *)_sink {
    self = [super init];
    if (self) {
        source = _source;
        sink = _sink;
    }
    return self;
}

- (id)initWithSource:(NWIOStream *)_source {
    return [self initWithSource:_source sink:nil];
}

- (id)initWithSink:(NWIOStream *)_sink {
    return [self initWithSource:nil sink:_sink];
}

- (id)initWithSourceAndSink:(NWIOStream *)sourceAndSink {
    return [self initWithSource:sourceAndSink sink:sourceAndSink];
}


- (void)setSourceAndSink:(NWIOStream *)sourceAndSink {
    self.source = sourceAndSink;
    self.sink = sourceAndSink;
}


#pragma mark - Drain

- (NSUInteger)run {
    void *drainBuffer = nil;
    BOOL freeWhenDone = NO;
    NSUInteger bLength = 0;
    if (buffered) {
        // drain uses it's own internal buffer
        if (!bufferLength) {
            bLength = NWIODefaultBufferLength;
        } else {
            bLength = bufferLength;
        }
        drainBuffer = malloc(bLength);
        if (drainBuffer) {
            memset(drainBuffer, 0, bLength);
            freeWhenDone = YES;
        }
    }
    NSUInteger result = 0;
    void *buffer = nil;
    for (NSUInteger read = 0;;) {
        if (!read) {
            // no leftovers so read from stream
            if (drainBuffer) {
                buffer = drainBuffer;
                read = [source read:buffer length:bLength];
            } else {
                read = [source readable:(const void **)&buffer];
            }
            if (!read) {
                if ([source hasReadEndedOrFailed:nil]) {
                    break;
                }
                continue;
            }
        }
        if (sink) {
            NSUInteger written = [sink write:buffer length:read];
            if (!written) {
                if ([sink hasWriteEndedOrFailed:nil]) {
                    break;
                }
                continue;
            }
            if (buffer) {
                buffer += written;
            }
            read -= written;
            result += written;
        } else {
            // no sink, just throw away those bytes
            read = 0;
        }
    }
    [source closeRead];
    [sink closeWrite];
    if (freeWhenDone) {
        free(drainBuffer);
    }
    return result;
}

- (void)rewind {
    [source rewindRead];
    [sink rewindWrite];
}

@end
