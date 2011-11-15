//
//  NWIOAccess.m
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

#import "NWIOAccess.h"


@implementation NWIOAccess

- (NSUInteger)inputLength {
    NSAssert(NO, @"inputLength not supported");
    return 0;
}

- (NSUInteger)outputLength {
    NSAssert(NO, @"outputLength not supported");
    return 0;
}

#pragma mark - Operations

- (NSUInteger)read:(void *)buffer range:(NSRange)range {
    NSAssert(NO, @"read not supported");
    return 0;
}

- (NSUInteger)readable:(const void **)buffer location:(NSUInteger)location {
    NSAssert(NO, @"readable not supported");
    return 0;
}

- (NSUInteger)write:(const void *)buffer range:(NSRange)range {
    NSAssert(NO, @"write not supported");
    return 0;
}

- (NSUInteger)writable:(void **)buffer location:(NSUInteger)location {
    NSAssert(NO, @"writable not supported");
    return 0;
}

@end