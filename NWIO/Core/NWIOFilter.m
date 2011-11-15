//
//  NWIOFilter.m
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

#import "NWIOFilter.h"


@implementation NWIOFilterStream

@synthesize stream;


#pragma mark - Object life cycle

- (id)init {
    // this we need, so subclasses get their initWithStream called
    return [self initWithStream:nil];
}

- (id)initWithStream:(NWIOStream *)_stream {
    self = [super init];
    if (self) {
        stream = _stream;
    }
    return self;
}


#pragma mark - Controls

- (BOOL)hasReadBytesAvailable {
    BOOL result = [super hasReadBytesAvailable];
    if (result) {
        // super says there is more
        return result;
    }
    return [stream hasReadBytesAvailable];
}

- (NSError *)readError {
    return [stream readError];
}

- (NSError *)writeError {
    return [stream writeError];
}

- (void)rewindRead {
    [super rewindRead];
    [stream rewindRead];
}

- (void)rewindWrite {
    [super rewindWrite];
    [stream rewindWrite];
}

- (void)closeRead {
    [super closeRead];
    [stream closeRead];
}

- (void)closeWrite {
    [super closeWrite];
    [stream closeWrite];
}

- (void)sever {
    // super can't sever
    [stream sever];
    stream = nil;
}

@end


@implementation NWIOFilterAccess

@synthesize access;


#pragma mark - Object life cycle

- (id)initWithAccess:(NWIOAccess *)_access {
    self = [super init];
    if (self) {
        access = _access;
    }
    return self;
}


#pragma mark - Controls

- (void)sever {
    access = nil;
}

@end