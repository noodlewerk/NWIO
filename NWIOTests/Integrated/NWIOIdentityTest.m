//
//  NWIOIdentityTest.m
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

#import "NWIOIdentityTest.h"
#import "NWIO.h"
#import "NWIOTestData.h"


@implementation NWIOIdentityTest {
    NSArray *datas;
}

- (void)checkIdentity:(NWIOFilterStream *)filter {
    NWIODataStream *inputStream = [[NWIODataStream alloc] init];
    for (NSData *inputData in datas) {
        [inputStream setInput:inputData];
        filter.stream = inputStream;
        [filter rewindRead];

        NSData *outputData = [filter drainFromInputToDataBuffered:YES];

        if (![inputData isEqualToData:outputData]) {
            NSLog(@"should be equal: %@==%@  %@", inputData, outputData, filter);
            NSAssert(NO, @"should be equal: %@==%@", inputData, outputData);
        }
    }

}

- (void)test {
    datas = [NWIOTestData datas];
    NSArray *transforms = [NWIOTestData transforms];

    for (NWIOTransform *transform in transforms) {
        NWIOChain *forback = [[NWIOChain alloc] init];
        [forback addFilter:[[NWIOTransformStream alloc] initWithStream:nil transform:transform inverted:YES]];
        [forback addFilter:[[NWIOTransformStream alloc] initWithStream:nil transform:transform]];
        [self checkIdentity:forback];
    }
}

@end
