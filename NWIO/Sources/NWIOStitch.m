//
//  NWIOStitch.m
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

#import "NWIOStitch.h"


@implementation NWIOStitchStream {
    NSUInteger readIndex;
    NSUInteger writeIndex;
}

@synthesize streams;


#pragma mark - Object life cycle

- (id)initWithStreams:(NSArray *)_streams {
    self = [super init];
    if (self) {
        streams = _streams;
    }
    return self;
}


#pragma mark - NWIOStream subclass

- (NSUInteger)read:(void *)buffer length:(NSUInteger)length {
    if (readIndex >= streams.count) {
        return 0;
    }
    NSUInteger result = 0;
    for (NSUInteger count = streams.count; readIndex < count; readIndex++) {
        NWIOStream *stream = [streams objectAtIndex:readIndex];
        NSUInteger read = [[streams objectAtIndex:readIndex] read:buffer length:length];
        if (read >= length) {
            return result + length;
        }
        if (read) {
            buffer += read;
            length -= read;
            result += read;
        } else if(result != 0 || [stream hasReadBytesAvailable]) {
            return result;
        }
    }
    return result;
}

- (NSUInteger)readable:(const void **)buffer {
    if (readIndex >= streams.count) {
        return 0;
    }
    for (; readIndex < streams.count; readIndex++) {
        NWIOStream *stream = [streams objectAtIndex:readIndex];
        NSUInteger result = [stream readable:buffer];
        if (result != 0 || [stream hasReadBytesAvailable]) {
            return result;
        }
    }
    return 0;
}

- (NSUInteger)write:(const void *)buffer length:(NSUInteger)length {
    if (writeIndex >= streams.count) {
        return 0;
    }
    for (; writeIndex < streams.count; writeIndex++) {
        NWIOStream *stream = [streams objectAtIndex:writeIndex];
        NSUInteger result = [stream write:buffer length:length];
        if (result != 0 || [stream hasWriteSpaceAvailable]) {
            return result;
        }
    }
    return 0;
}

- (NSUInteger)writable:(void **)buffer {
    if (writeIndex >= streams.count) {
        return 0;
    }
    for (; writeIndex < streams.count; writeIndex++) {
        NWIOStream *stream = [streams objectAtIndex:writeIndex];
        NSUInteger result = [stream writable:buffer];
        if (result != 0 || [stream hasWriteSpaceAvailable]) {
            return result;
        }
    }
    return 0;
}

- (void)unwritable:(NSUInteger)length {
    // TODO implement
}


#pragma mark - Controls

- (BOOL)hasReadBytesAvailable {
    if (readIndex < streams.count) {
        return YES;
    }
    return [super hasReadBytesAvailable];
}

- (BOOL)hasWriteSpaceAvailable {
    if (writeIndex < streams.count) {
        return YES;
    }
    return [super hasWriteSpaceAvailable];
}

- (void)rewindRead {
    [super rewindRead];
    readIndex = 0;
}

- (void)rewindWrite {
    [super rewindWrite];
    writeIndex = 0;
}

- (void)closeRead {
    [super closeRead];
    // TODO
}

- (void)closeWrite {
    [super closeWrite];
    // TODO
}

// being a kind-a-filter, we respond to sever
- (void)sever {
    streams = nil;
}

- (id)control:(id)control {
    // forward to all sub-streams
    for (NWIOStream *stream in streams) {
        [super control:control];
    }
    return nil;
}

@end


@implementation NWIOStitchAccess {
    NSUInteger *cumulativeLengths;
}

@synthesize accesses;


#pragma mark - Object life cycle

// Store cumulated lengths for binary search later on
+ (NSUInteger *)cumulateLengthsAccesses:(NSArray *)accesses {
    NSUInteger *result = malloc(accesses.count * sizeof(NSUInteger));
    NSUInteger sum = 0, i = 0;
    for (NWIOAccess *access in accesses) {
        sum += access.inputLength;
        result[i++] = sum;
    }
    return result;
}

- (id)initWithAccesses:(NSArray *)_accesses {
    self = [super init];
    if (self) {
        accesses = _accesses;
        if (accesses.count) {
            cumulativeLengths = [NWIOStitchAccess cumulateLengthsAccesses:accesses];
        }
    }
    return self;
}

- (void)dealloc {
    if (cumulativeLengths) {
        free(cumulativeLengths); cumulativeLengths = NULL;
    }
}


#pragma mark - Stitch

// Findes access that covers the location of given range
- (NWIOAccess *)accessWithRange:(NSRange *)range {
    NSUInteger location = range->location;
    if (cumulativeLengths && location < cumulativeLengths[accesses.count]) {
        // binary search on cumulative lengths
        NSUInteger min = 0, max = accesses.count - 1;
        while (min < max) {
            NSUInteger mid = (min + max) / 2;
            if (location < cumulativeLengths[mid]) {
                max = mid;
            } else {
                min = mid + 1;
            }
        }
        // return found access and clamp range
        NWIOAccess *result = [accesses objectAtIndex:min];
        range->location -= cumulativeLengths[min];
        if (range->location + range->length > result.inputLength) {
            range->length = result.inputLength - range->location;
        }
        return result;
    }
    return nil;
}


#pragma mark - NWIOAccess subclass

- (NSUInteger)length {
    return cumulativeLengths[accesses.count];
}

// TODO: consider performing multiple reads/writes to cover whole range

- (NSUInteger)read:(void *)buffer range:(NSRange)range {
//    if (range.location >= inputLength) {
//        range.length = 0;
//    } else if (range.location + range.length > inputLength) {
//        range.length = inputLength - range.location;
//    }
    [[self accessWithRange:&range] read:buffer range:range];
    return 0;
}

- (NSUInteger)write:(const void *)buffer range:(NSRange)range {
//    if (range.location >= outputLength) {
//        range.length = 0;
//    } else if (range.location + range.length > outputLength) {
//        range.length = outputLength - range.location;
//    }
    [[self accessWithRange:&range] write:buffer range:range];
    return 0;
}


#pragma mark - Controls

// being a kind-a-filter, we respond to sever
- (void)sever {
    [super sever];
    accesses = nil;
}

- (id)control:(id)control {
    // forward to all sub-accesses
    for (NWIOStream *access in accesses) {
        [super control:control];
    }
    return nil;
}

@end
