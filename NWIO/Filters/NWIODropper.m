//
//  NWIODropper.m
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

#import "NWIODropper.h"


@implementation NWIODropperStream

@synthesize dropSize;


#pragma mark - Object life cycle

- (id)initWithStream:(NWIOStream *)_stream {
    return [self initWithStream:_stream dropSize:1];
}

- (id)initWithStream:(NWIOStream *)_stream dropSize:(NSUInteger)_dropSize {
    self = [super initWithStream:_stream];
    if (self) {
        dropSize = _dropSize > 0 ? _dropSize : 1;
    }
    return self;
}

#pragma mark - NWIOStream subclass

- (NSUInteger)read:(void *)buffer length:(NSUInteger)length {
    return [stream read:buffer length:dropSize < length ? dropSize : length];
}

- (NSUInteger)write:(const void *)buffer length:(NSUInteger)length {
    return [stream write:buffer length:dropSize < length ? dropSize : length];
}

@end
