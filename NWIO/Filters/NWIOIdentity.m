//
//  NWIOIdentity.m
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

#import "NWIOIdentity.h"


@implementation NWIOIdentityStream


#pragma mark - NWIOStream subclass

- (NSUInteger)read:(void *)buffer length:(NSUInteger)length {
    return [stream read:buffer length:length];
}

- (NSUInteger)readable:(const void **)buffer {
    return [stream readable:buffer];
}

- (NSUInteger)write:(const void *)buffer length:(NSUInteger)length {
    return [stream write:buffer length:length];
}

- (NSUInteger)writable:(void **)buffer {
    return [stream writable:buffer];
}

- (void)unwritable:(NSUInteger)length {
    [stream unwritable:length];
}


#pragma mark - Controls

- (BOOL)hasReadBytesAvailable {
    // no need to call super stream
    return [stream hasReadBytesAvailable];
}

- (void)rewindRead {
    // no need to call super
    [stream rewindRead];
}

- (void)rewindWrite {
    // no need to call super
    [stream rewindWrite];
}

- (void)closeWrite {
    // no need to call super
    [stream closeWrite];
}

@end
