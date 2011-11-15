//
//  NWIOStitchTest.m
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

#import "NWIOStitchTest.h"
#import "NWIO.h"


@implementation NWIOStitchTest

- (void)test {
    NWIODataStream *stream1 = [[NWIODataStream alloc] initWithInput:[@"For the specific langu" dataUsingEncoding:NSUTF8StringEncoding]];
    NWIODataStream *stream2 = [[NWIODataStream alloc] initWithInput:[@"age governing permissions" dataUsingEncoding:NSUTF8StringEncoding]];
    NWIOStitchStream *stitch = [[NWIOStitchStream alloc] initWithStreams:[NSArray arrayWithObjects:stream1, stream2, nil]];
    const void *buffer = NULL;
    NSUInteger l = 0;
    l = [stitch readable:&buffer];
    NSString *a = [NSString stringWithFormat:@"%.*s", l, buffer];
    NSAssert([a isEqualToString:@"For the specific langu"], @"");
    l = [stitch readable:&buffer];
    NSString *b = [NSString stringWithFormat:@"%.*s", l, buffer];
    NSAssert([b isEqualToString:@"age governing permissions"], @"");
}

@end
