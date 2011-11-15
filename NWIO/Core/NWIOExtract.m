//
//  NWIOExtract.m
//  NWIO
//
//  Copyright (c) 2011 Noodlewerk
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

#import "NWIOExtract.h"


@implementation NWIOExtract

- (void)extractFrom:(const unsigned char *)buffer length:(NSUInteger)length {
    NSAssert(NO, @"Implement extract: %@", self);
}

@end



@implementation NWIOExtractStream

@synthesize inputExtract, outputExtract;


#pragma mark - Object life cycle

- (id)initWithStream:(NWIOStream *)_stream inputExtract:(NWIOExtract *)_inputExtract outputExtract:(NWIOExtract *)_outputExtract {
    self = [super initWithStream:_stream];
    if (self) {
        inputExtract = _inputExtract;
        outputExtract = _outputExtract;
    }
    return self;
}

#pragma mark - NWIOStream subclass

- (NSUInteger)read:(void *)buffer length:(NSUInteger)length {
    NSUInteger result = [stream read:buffer length:length];
    [inputExtract extractFrom:buffer length:result];
    return result;
}

- (NSUInteger)readable:(const void **)buffer {
    NSUInteger result = [stream readable:buffer];
    [inputExtract extractFrom:*buffer length:result];
    return result;
}

- (NSUInteger)write:(const void *)buffer length:(NSUInteger)length {
    NSUInteger result = [stream write:buffer length:length];
    [outputExtract extractFrom:buffer length:result];
    return result;
}

// TODO:
//- (NSUInteger)writable:(void **)buffer {
//    NSUInteger result = [stream writable:buffer];
//    [outputExtract extractFrom:buffer length:result];
//    return result;
//}

//- (void)unwritable:(NSUInteger)length {
//    [stream unwritable:length];
//}

@end
