//
//  NWIOBidirectionalTest.m
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

#import "NWIOBidirectionalTest.h"
#import "NWIO.h"
#import "NWIOTestData.h"


@implementation NWIOBidirectionalTest

- (void)test {
    NSArray *datas = [NWIOTestData datas];
    NSArray *filters = [NWIOTestData filters];

    NSMutableData *bufferData = [NSMutableData data];
    NSMutableData *outputData = [NSMutableData data];

    NWIODataStream *inputStream = [[NWIODataStream alloc] init] ;
    NWIODataStream *bufferStream = [[NWIODataStream alloc] initWithInput:bufferData output:bufferData] ;
    NWIODataStream *outputStream = [[NWIODataStream alloc] initWithOutput:outputData] ;

    NWIODrain *writeDrain = [[NWIODrain alloc] initWithSource:inputStream] ;
    NWIODrain *readDrain = [[NWIODrain alloc] initWithSink:outputStream] ;

    for (NWIOFilterStream *filter in filters) {
        filter.stream = bufferStream;
        writeDrain.sink = filter;
        readDrain.source = filter;


        for (NSData *inputData in datas) {
            [inputStream setInput:inputData];
            [outputData setLength:0];
            [bufferData setLength:0];

            // write data
            [writeDrain rewind];
            [writeDrain run];

            // read data
            [readDrain rewind];
            [readDrain run];
            if (![inputData isEqualToData:outputData]) {
//                NSLog(@"should be equal: %@==%@  %@", inputData, outputData, filter);
//                NSLog(@"%.*s",bufferData.length, bufferData.bytes);
                NSAssert(NO, @"should be equal: %@==%@", inputData, outputData);
            }
        }
    }
}

- (void)testSingle {
    NSMutableData *bufferData = [NSMutableData data];
    NSMutableData *outputData = [NSMutableData data];

    NWIODataStream *inputStream = [[NWIODataStream alloc] init];
    NWIODataStream *bufferStream = [[NWIODataStream alloc] initWithInput:bufferData output:bufferData] ;
    NWIODataStream *outputStream = [[NWIODataStream alloc] initWithOutput:outputData] ;

    NWIODrain *writeDrain = [[NWIODrain alloc] initWithSource:inputStream] ;
    NWIODrain *readDrain = [[NWIODrain alloc] initWithSink:outputStream] ;

    NWIOFilterStream *filter = [[NWIOIdentityStream alloc] init] ;
    filter.stream = bufferStream;
    writeDrain.sink = filter;
    readDrain.source = filter;

    NSData *inputData = [@"test" dataUsingEncoding:NSUTF8StringEncoding];

    [inputStream setInput:inputData];
    [outputData setLength:0];
    [bufferData setLength:0];

    // write data
    [writeDrain rewind];
    [writeDrain run];

    // read data
    [readDrain rewind];
    [readDrain run];

    if (![inputData isEqualToData:outputData]) {
//        NSLog(@"should be equal: %@==%@  %@", inputData, outputData, filter);
//        NSLog(@"%.*s",bufferData.length, bufferData.bytes);
        NSAssert(NO, @"should be equal: %@==%@", inputData, outputData);
    }
}

@end
