//
//  NWIODropperTest.m
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

#import "NWIODropperTest.h"
#import "NWIO.h"

@implementation NWIODropperTest

- (void)test {
    unsigned char read[10];
    NWIODropperStream *dropper = [[NWIODropperStream alloc] initWithInputString:@"WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND," outputString:nil];

    NSUInteger r1 = [dropper read:read length:sizeof(read)];
    NSAssert(r1 == 1, @"Should be 1: %i", r1);
    NSAssert(read[0] == 'W', @"Should be 'W': %c", read[0]);
    NSUInteger r2 = [dropper read:read length:sizeof(read)];
    NSAssert(r2 == 1, @"Should be 1: %i", r1);
    NSAssert(read[0] == 'I', @"Should be 'I': %c", read[0]);
    
    const unsigned char *readable = nil;
    NSUInteger r3 = [dropper readable:(const void **)&readable];
    NSAssert(r3 == 1, @"Should be 1: %i", r3);
    NSAssert(readable && readable[0] == 'T', @"Should be 'T': %c", readable[0]);
    NSUInteger r4 = [dropper readable:(const void **)&readable];
    NSAssert(r4 == 1, @"Should be 1: %i", r4);
    NSAssert(readable && readable[0] == 'H', @"Should be 'H': %c", readable[0]);
}

@end
