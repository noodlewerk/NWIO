//
//  NWIODeflateTest.m
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

#import "NWIODeflateTest.h"
#import "NWIOTransformTesting.h"
#import "NWIO.h"
#import "NWIOTestTools.h"

@implementation NWIODeflateTest

- (void)test {
    NSString *plainText = @"For the specific language governing permissions";
    NSData *deflated = DATA(@"789C05C1810DC0200C03B05772CDFE402894485B8B5AD8FDD84F24F6246AB16BA8E36D6EA71961F1335D6E58CC4F550AAF0BA496121E");

    {
        NWIODeflateStream *stream = [[NWIODeflateStream alloc] initWithInputData:deflated outputData:nil];

        [stream rewindRead];
        NSString *buffered = [stream drainFromInputToStringBuffered:YES];
        NSAssert([buffered isEqualToString:plainText], @"");

        [stream rewindRead];
        NSString *unbufferd = [stream drainFromInputToStringBuffered:NO];
        NSAssert([unbufferd isEqualToString:plainText], @"");

        [stream rewindRead];
        NSString *dropped = [[[NWIODropperStream alloc] initWithStream:stream] drainFromInputToStringBuffered:NO];
        NSAssert([dropped isEqualToString:plainText], @"");
    }

    {
        NWIODeflateStream *stream = [[NWIODeflateStream alloc] initWithInputString:plainText outputString:nil];
        [stream invert];

        [stream rewindRead];
        NSData *buffered = [stream drainFromInputToDataBuffered:YES];
        NSAssert([buffered isEqualToData:deflated], @"");

        [stream rewindRead];
        NSData *unbufferd = [stream drainFromInputToDataBuffered:NO];
        NSAssert([unbufferd isEqualToData:deflated], @"");

        [stream rewindRead];
        NSData *dropped = [[[NWIODropperStream alloc] initWithStream:stream] drainFromInputToDataBuffered:NO];
        NSAssert([dropped isEqualToData:deflated], @"");
    }
}

@end
