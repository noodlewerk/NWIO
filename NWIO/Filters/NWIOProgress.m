//
//  NWIOProgress.m
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

#import "NWIOProgress.h"


@implementation NWIOProgressStream {
    NSUInteger lastLength;
    double lastRatio;
}

@synthesize streamedLength, expectedLength, intervalRatio, intervalLength;
@synthesize blocksQueue, didStreamLengthBlock, didStreamRatioBlock, didFinishWithLengthBlock;


#pragma mark - Object life cycle

- (id)initWithStream:(NWIOStream *)_stream {
    self = [super initWithStream:_stream];
    if (self) {
        blocksQueue = [NSOperationQueue currentQueue];
    }
    return self;
}


#pragma mark - Progress

- (void)progress:(NSUInteger)result {
    streamedLength += result;
    if (didStreamLengthBlock) {
        if (!intervalLength) {
            void(^b)(NSUInteger) = didStreamLengthBlock;
            NSUInteger i = streamedLength;
            [blocksQueue addOperationWithBlock:^{b(i);}];
        } else while(streamedLength >= lastLength + intervalLength) {
            lastLength += intervalLength;
            NSUInteger l = lastLength;
            void(^b)(NSUInteger) = didStreamLengthBlock;
            [blocksQueue addOperationWithBlock:^{b(l);}];
        }
    }
    if (didStreamRatioBlock && expectedLength) {
        double streamedRatio = (double)streamedLength / expectedLength;
        if (!intervalRatio) {
            void(^b)(double) = didStreamRatioBlock;
            [blocksQueue addOperationWithBlock:^{b(streamedRatio);}];
        } else while(streamedRatio >= lastRatio + intervalRatio) {
            lastRatio += intervalRatio;
            double r = lastRatio;
            void(^b)(double) = didStreamRatioBlock;
            [blocksQueue addOperationWithBlock:^{b(r);}];
        }
    }
}


#pragma mark - NWIOStream subclass

- (NSUInteger)read:(void *)buffer length:(NSUInteger)length {
    NSUInteger result = [super read:buffer length:length];
    [self progress:result];
    return result;
}

- (NSUInteger)readable:(const void **)buffer {
    NSUInteger result = [super readable:buffer];
    [self progress:result];
    return result;
}

- (NSUInteger)write:(const void *)buffer length:(NSUInteger)length {
    NSUInteger result = [super write:buffer length:length];
    [self progress:result];
    return result;
}

- (NSUInteger)writable:(void **)buffer {
    NSUInteger result = [super writable:buffer];
    [self progress:result];
    return result;
}

@end

