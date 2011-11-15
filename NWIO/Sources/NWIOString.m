//
//  NWIOString.m
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

#import "NWIOString.h"
#import "NWIOData.h"



@implementation NWIOStringStream {
    NSUInteger inputLocation;
    NSUInteger outputLocation;
}

@synthesize input, output, outputLengthFixed;


#pragma mark - Object life cycle

- (id)initWithInput:(NSString *)_input output:(NSMutableString *)_output {
    self = [super init];
    if (self) {
        input = _input;
        output = _output;
    }
    return self;
}

- (id)initWithInput:(NSString *)_input {
    return [self initWithInput:_input output:nil];
}

- (id)initWithOutput:(NSMutableString *)_output {
    return [self initWithInput:nil output:_output];
}


#pragma mark - NWIOStream subclass

- (NSUInteger)read:(void *)buffer length:(NSUInteger)length {
    if (inputLocation < input.length) {
        if (inputLocation + length > input.length) {
            length = input.length - inputLocation;
        }
        if (buffer) {
            unichar *characters = malloc(sizeof(unichar) * length);
            [input getCharacters:characters range:NSMakeRange(inputLocation, length)];
            for (int i = 0; i < length; i++) {
                ((unsigned char *)buffer)[i] = characters[i];
            }
            free(characters);
        }
        inputLocation += length;
        return length;
    }
    return 0;
}

// TODO: make use of the fixed length property, see NWIODataStream
- (NSUInteger)write:(const void *)buffer length:(NSUInteger)length {
    if (buffer) {
        unichar *characters = malloc(sizeof(unichar) * length);
        for (int i = 0; i < length; i++) {
            characters[i] = ((unsigned char *)buffer)[i];
        }
        [output appendString:[NSString stringWithCharacters:characters length:length]];
        free(characters);
    }
    return length;
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

- (void)rewindRead {
    [super rewindRead];
    inputLocation = 0;
}

- (void)rewindWrite {
    [super rewindWrite];
    outputLocation = 0;
}

- (void)sever {
    // super can't sever
    input = nil;
    output = nil;
}

@end