//
//  NWIOData.m
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

#import "NWIOData.h"


@implementation NWIODataStream {
    NSUInteger inputLocation;
    NSUInteger outputLocation;
}

@synthesize input, output, outputLengthFixed, outputExpandLength;


#pragma mark - Object life cycle

- (id)initWithInput:(NSData *)_input output:(NSMutableData *)_output {
    self = [super init];
    if (self) {
        input = _input;
        output = _output;
    }
    return self;
}

- (id)initWithInput:(NSData *)_input {
    return [self initWithInput:_input output:nil];
}

- (id)initWithOutput:(NSMutableData *)_output {
    return [self initWithInput:nil output:_output];
}

- (id)initWithInputURL:(NSURL *)url {
    return [self initWithInput:[NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:nil]];
}


#pragma mark - NWIOStream subclass

- (NSUInteger)read:(void *)buffer length:(NSUInteger)length {
    if (inputLocation < input.length) {
        if (inputLocation + length > input.length) {
            length = input.length - inputLocation;
        }
        if (buffer) {
            [input getBytes:buffer range:NSMakeRange(inputLocation, length)];
        }
        inputLocation += length;
        return length;
    }
    return 0;
}

- (NSUInteger)readable:(const void **)buffer {
    if (inputLocation < input.length) {
        if (buffer) {
            *buffer = input.bytes + inputLocation;
        }
        NSUInteger result = input.length - inputLocation;
        inputLocation = input.length;
        return result;
    }
    return 0;
}

- (NSUInteger)write:(const void *)buffer length:(NSUInteger)length {
    if (!outputLengthFixed) {
        [output setLength:outputLocation + length];
    } else {
        // correct length according to output's fixed length
        if (outputLocation > output.length) {
            length = 0;
        } else if (outputLocation + length > output.length) {
            length = output.length - outputLocation;
        }
    }
    if (buffer && length) {
        [output replaceBytesInRange:NSMakeRange(outputLocation, length) withBytes:buffer];
    }
    outputLocation += length;
    return length;
}

- (NSUInteger)writable:(void **)buffer {
    if (!outputLengthFixed) {
        if (!outputExpandLength) {
            outputExpandLength = NWIODefaultBufferLength;
        }
        [output setLength:outputLocation + outputExpandLength];
    }
    if (buffer) {
        *buffer = output.mutableBytes + outputLocation;
    }
    NSUInteger result = output.length - outputLocation;
    outputLocation = output.length;
    return result;
}

- (void)unwritable:(NSUInteger)length {
    if (length < outputLocation) {
        outputLocation -= length;
    } else {
        outputLocation = 0;
    }
    if (!outputLengthFixed) {
        // minimize output length
        [output setLength:outputLocation];
    }
}


#pragma mark - Controls

- (BOOL)hasReadBytesAvailable {
    if (inputLocation < input.length) {
        return YES;
    }
    return [super hasReadBytesAvailable];
}

- (BOOL)hasWriteSpaceAvailable {
    if (outputLocation < output.length) {
        return YES;
    }
    return [super hasReadBytesAvailable];
}

- (NSError *)readError {
    // never errors
    return nil;
}

- (NSError *)writeError {
    // never errors
    return nil;
}

- (void)rewindRead {
    [super rewindRead];
    inputLocation = 0;
}

- (void)rewindWrite {
    [super rewindWrite];
    outputLocation = 0;
}

- (void)sever {
    [super sever];
    input = nil;
    output = nil;
}

@end


@implementation NWIODataAccess

@synthesize input, output;


#pragma mark - Object life cycle

- (id)initWithInput:(NSData *)_input output:(NSMutableData *)_output {
    self = [super init];
    if (self) {
        input = _input;
        output = _output;
    }
    return self;
}

- (id)initWithInput:(NSData *)_input {
    return [self initWithInput:_input output:nil];
}

- (id)initWithOutput:(NSMutableData *)_output {
    return [self initWithInput:nil output:_output];
}

- (id)initWithInputURL:(NSURL *)url {
    return [self initWithInput:[NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:nil]];
}

- (NSUInteger)inputLength {
    return input.length;
}

- (NSUInteger)outputLength {
    return output.length;
}

#pragma mark - NWIOAccess subclass

- (NSUInteger)read:(void *)buffer range:(NSRange)range {
    if (range.location >= input.length) {
        range.length = 0;
    } else if (range.location + range.length > input.length) {
        range.length = input.length - range.location;
    }
    if (buffer) {
        [input getBytes:buffer range:range];
    }
    return range.length;
}

- (NSUInteger)readable:(const void **)buffer location:(NSUInteger)location {
    if (location < input.length) {
        if (buffer) {
            *buffer = input.bytes + location;
        }
        return input.length - location;
    }
    return 0;
}

- (NSUInteger)write:(const void *)buffer range:(NSRange)range {
    if (range.location >= output.length) {
        range.length = 0;
    } else if (range.location + range.length > output.length) {
        range.length = output.length - range.location;
    }
    if (buffer) {
        [output replaceBytesInRange:range withBytes:buffer];
    }
    return range.length;
}

- (NSUInteger)writable:(void **)buffer location:(NSUInteger)location {
    if (location < output.length) {
        if (buffer) {
            *buffer = output.mutableBytes + location;
        }
        return output.length - location;
    }
    return 0;
}


#pragma mark - Controls

- (void)sever {
    [super sever];
    input = nil;
    output = nil;
}

@end
