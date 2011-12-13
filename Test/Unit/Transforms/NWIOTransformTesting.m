//
//  NWIOTransformTesting.m
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

#import "NWIOTransformTesting.h"
#import "NWIO.h"


@implementation NWIOTransformTesting

+ (void)testTransform:(NWIOTransform *)transform plainString:(NSString *)plain codedString:(NSString *)coded {
    [self testTransform:transform plain:[plain dataUsingEncoding:NSUTF8StringEncoding] coded:[coded dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (void)testTransform:(NWIOTransform *)transform plain:(NSData *)plain coded:(NSData *)coded {
    NSMutableData *codedOut = [NSMutableData dataWithCapacity:coded.length];
    NWIODataStream *dataStream = [[NWIODataStream alloc] initWithInput:coded output:codedOut];
    NWIOTransformStream *transfromStream = [[NWIOTransformStream alloc] initWithStream:dataStream transform:transform];
    NSData *plainOut = [transfromStream drainFromInputToDataBuffered:YES];
    NSAssert([plain isEqualToData:plainOut], @"backward transform failed");
    [transfromStream drainFromDataToOutput:plain bufferd:YES];
    NSAssert([coded isEqualToData:codedOut], @"forward transform failed");
}


+ (void)testSingleTransform:(NWIOTransform *)transform plainString:(NSString *)plain codedString:(NSString *)coded {
    [self testSingleTransform:transform plain:[plain dataUsingEncoding:NSUTF8StringEncoding] coded:[coded dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (void)testSingleTransform:(NWIOTransform *)transform plain:(NSData *)plain coded:(NSData *)coded {
    unsigned char buffer[256];

    {
        NSUInteger fromInc = 0;
        NSUInteger toInc = 0;
        memset(buffer, 0, sizeof(buffer));
        NSError *error = nil;

        BOOL forward = [transform transformForwardFromBuffer:(const unsigned char *)plain.bytes fromLength:plain.length fromInc:&fromInc toBuffer:buffer toLength:sizeof(buffer) toInc:&toInc error:&error];

        NSAssert(forward == YES, @"Should be equal YES");
        NSAssert(error == nil, @"Should be equal nil");
        NSAssert(fromInc == plain.length, @"Should be equal: %i==%i", fromInc, plain.length);
        NSAssert(toInc == coded.length, @"Should be equal: %i==%i", toInc, coded.length);
        NSAssert(memcmp(buffer, coded.bytes, coded.length) == 0, @"Should be equal: %.*s==%.*s", coded.length, buffer, coded.length, coded.bytes);
    }

    {
        NSUInteger fromInc = 0;
        NSUInteger toInc = 0;
        memset(buffer, 0, sizeof(buffer));
        NSError *error = nil;

        BOOL backward = [transform transformBackwardFromBuffer:(const unsigned char *)coded.bytes fromLength:coded.length fromInc:&fromInc toBuffer:buffer toLength:sizeof(buffer) toInc:&toInc error:&error];

        NSAssert(backward == YES, @"Should be equal YES");
        NSAssert(error == nil, @"Should be equal nil");
        NSAssert(fromInc == coded.length, @"Should be equal: %i==%i", fromInc, plain.length);
        NSAssert(toInc == plain.length, @"Should be equal: %i==%i", toInc, coded.length);
        NSAssert(memcmp(buffer, plain.bytes, plain.length) == 0, @"Should be equal: %.*s==%.*s", plain.length, buffer, plain.length, plain.bytes);
    }
}

@end
