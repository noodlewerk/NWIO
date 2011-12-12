//
//  NWIOChain.m
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

#import "NWIOChain.h"


@implementation NWIOChainStream {
    NWIOFilterStream *first;
}

- (void)addFilter:(NWIOFilterStream *)filter {
    if (!first) {
        // this is the first link of the chain, keep it for setStream:
        first = filter;
    }
    // this new link reads from the previous one
    filter.stream = stream;
    // and will become the previous
    stream = filter;
}

- (void)setStream:(NWIOStream *)_stream {
    if (first) {
        // the first link reads from this stream
        first.stream = _stream;
    } else {
        // same as initWithStream
        stream = _stream;
    }
}

@end



@implementation NWIOChainAccess {
    NWIOFilterAccess *first;
}

- (void)addFilter:(NWIOFilterAccess *)filter {
    if (!first) {
        // this is the first link of the chain, keep it for setStream:
        first = filter;
    }
    // this new link reads from the previous one
    filter.access = access;
    // and will become the previous
    access = filter;
}

- (void)setAccess:(NWIOAccess *)_access {
    if (first) {
        // the first link reads from this stream
        first.access = _access;
    } else {
        // same as initWithStream
        access = _access;
    }
}

@end
