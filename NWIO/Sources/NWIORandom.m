//
//  NWIORandom.m
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

#import "NWIORandom.h"


@implementation NWIORandomStream {
    NSUInteger readLength;
    NSUInteger writtenLength;
}

@synthesize inputLength, outputLength;


#pragma mark - Object life cycle

- (id)initWithInputLength:(NSUInteger)input outputLength:(NSUInteger)output {
    self = [super init];
    if (self) {
        inputLength = input;
        outputLength = output;
    }
    return self;
}

+ (void)fillBuffer:(void *)buffer length:(NSUInteger)length {
    for (unsigned char *i = buffer, *end = i + length; i < end; i++) {
        *i = (unsigned char)(256 * (float)rand() / RAND_MAX);
    }
}


#pragma mark - NWIOStream subclass

- (NSUInteger)read:(void *)buffer length:(NSUInteger)length {
    if (readLength + length > inputLength) {
        length = inputLength - readLength;
    }
    if (buffer) {
        [NWIORandomStream fillBuffer:buffer length:length];
    }
    readLength += length;
    return length;
}

- (NSUInteger)write:(const void *)buffer length:(NSUInteger)length {
    if (writtenLength + length > outputLength) {
        length = outputLength - writtenLength;
    }
    writtenLength += length;
    return length;
}


#pragma mark - Controls

- (BOOL)hasReadBytesAvailable {
    if (readLength < inputLength) {
        return YES;
    }
    return [super hasReadBytesAvailable];
}

- (BOOL)hasWriteSpaceAvailable {
    if (writtenLength < outputLength) {
        return YES;
    }
    return [super hasWriteSpaceAvailable];
}

- (void)rewindRead {
    readLength = 0;
}

- (void)rewindWrite {
    writtenLength = 0;
}

@end


@implementation NWIORandomAccess

@synthesize inputLength, outputLength;


#pragma mark - Object life cycle

- (id)initWithInputLength:(NSUInteger)input outputLength:(NSUInteger)output {
    self = [super init];
    if (self) {
        inputLength = input;
        outputLength = output;
    }
    return self;
}


#pragma mark - NWIOAccess subclass

- (NSUInteger)read:(void *)buffer range:(NSRange)range {
    if (range.location >= inputLength) {
        range.length = 0;
    } else if (range.location + range.length > inputLength) {
        range.length = inputLength - range.location;
    }
    if (buffer) {
        [NWIORandomStream fillBuffer:buffer length:range.length];
    }
    return range.length;
}

- (NSUInteger)write:(const void *)buffer range:(NSRange)range {
    if (range.location >= outputLength) {
        range.length = 0;
    } else if (range.location + range.length > outputLength) {
        range.length = outputLength - range.location;
    }
    // access does not store any data, so this is a no-op
    return range.length;
}

@end

