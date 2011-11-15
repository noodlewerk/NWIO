//
//  NWIOConstant.m
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

#import "NWIOConstant.h"


@implementation NWIOConstantStream {
    NSUInteger readLength;
    NSUInteger writtenLength;
}

@synthesize constant, inputLength, outputLength;


#pragma mark - Object life cycle

- (id)initWithInputLength:(NSUInteger)input outputLength:(NSUInteger)output {
    self = [super init];
    if (self) {
        inputLength = input;
        outputLength = output;
    }
    return self;
}


#pragma mark - NWIOStream subclass

- (NSUInteger)read:(void *)buffer length:(NSUInteger)length {
    if (readLength + length > inputLength) {
        length = inputLength - readLength;
    }
    if (buffer && length) {
        memset(buffer, constant, length);
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



@implementation NWIOConstantAccess

@synthesize constant, inputLength, outputLength;


#pragma mark - Object life cycle

- (id)initWithInputLength:(NSUInteger)input outputLength:(NSUInteger)output {
    self = [super init];
    if (self) {
        inputLength = input;
        outputLength = output;
        constant = 0;
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
        memset(buffer, constant, range.length);
    }
    return range.length;
}

- (NSUInteger)write:(const void *)buffer range:(NSRange)range {
    if (range.location >= outputLength) {
        range.length = 0;
    } else if (range.location + range.length > outputLength) {
        range.length = outputLength - range.location;
    }
    // access is constant, so this is a no-op
    return 0;
}

@end

