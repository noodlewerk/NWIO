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
    if (stream) {
        return [stream read:buffer length:length];
    } else {
        // TODO: reconsider this; maybe not read zeros, only allow writing
        memset(buffer, 0, length);
        return length;
    }
}

- (NSUInteger)readable:(const void **)buffer {
    if (stream) {
        return [stream readable:buffer];
    } else {
        return [super readable:buffer];
    }
}

- (NSUInteger)write:(const void *)buffer length:(NSUInteger)length {
    if (stream) {
        return [stream write:buffer length:length];
    } else {
        return length;
    }
}

- (NSUInteger)writable:(void **)buffer {
    if (stream) {
        return [stream writable:buffer];
    } else {
        return [super writable:buffer];
    }
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



@implementation NWIOIdentityAccess


#pragma mark - NWIOAccess subclass

- (NSUInteger)read:(void *)buffer range:(NSRange)range {
    if (access) {
        return [access read:buffer range:range];
    } else {
        // TODO: reconsider this; maybe not read zeros, only allow writing
        memset(buffer, 0, range.length);
        return range.length;
    }
}

- (NSUInteger)readable:(const void **)buffer location:(NSUInteger)location {
    if (access) {
        return [access readable:buffer location:location];
    } else {
        return [super readable:buffer location:location];
    }
}

- (NSUInteger)write:(const void *)buffer range:(NSRange)range {
    if (access) {
        return [access write:buffer range:range];
    } else {
        return range.length;
    }
}

- (NSUInteger)writable:(void **)buffer location:(NSUInteger)location {
    if (access) {
        return [access writable:buffer location:location];
    } else {
        return [super writable:buffer location:location];
    }
}


#pragma mark - Control

- (NSUInteger)inputLength {
    return access.inputLength;
}

- (NSUInteger)outputLength {
    return access.outputLength;
}

@end
