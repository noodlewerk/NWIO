//
//  NWIOTestData.m
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

#import "NWIOTestData.h"
#import "NWIO.h"

@implementation NWIOTestData

+ (NSArray *)datas {
    NSMutableArray *result = [NSMutableArray array];
    [result addObject:[NSData data]];
    [result addObject:[@"a" dataUsingEncoding:NSUTF8StringEncoding]];
    [result addObject:[@"test" dataUsingEncoding:NSUTF8StringEncoding]];
    [result addObject:[@"And when we are obviously entered into that mode,\nyou can see a radical subjectivity,\nradical attunement to individuality, uniqueness to that which the mind is,\nopens itself to a vast objectivity." dataUsingEncoding:NSUTF8StringEncoding]];
    for (NSUInteger j = 1; j <= 26; j++) {
        [result addObject:[NSMutableData dataWithLength:j]];
        unsigned char *buffer = [[result lastObject] mutableBytes];
        for (NSUInteger i = 0; i < j; i++) {
            buffer[i] = 'a' + i;
        }
    }
    for (NSUInteger j = 1; j < 30; j++) {
        [result addObject:[NSMutableData dataWithLength:j]];
        unsigned char *buffer = [[result lastObject] mutableBytes];
        for (NSUInteger i = 0; i < j; i++) {
            buffer[i] = i;
        }
    }
    return result;
}

+ (NSArray *)filters {
    NSMutableArray *result = [NSMutableArray array];
    NSMutableArray *filters = [NSMutableArray array];
    [filters addObject:[[NWIOIdentityStream alloc] init]];
    [filters addObject:[[NWIOCaseFlipperStream alloc] init]];
    [filters addObject:[[NWIOHcodeStream alloc] init]];
    [filters addObject:[[NWIOZcodeStream alloc] init]];
    [filters addObject:[[NWIODeflateStream alloc] init]];
    [filters addObject:[[NWIOCryptoStream alloc] init]];
    [result addObjectsFromArray:filters];
    [result addObject:[[NWIOChainStream alloc] init]];
    for (NWIOFilterStream *filter in filters) {
        [[result lastObject] addFilter:filter];
    }
    return result;
}

+ (NSArray *)transforms {
    NSMutableArray *result = [NSMutableArray array];
    [result addObject:[[NWIOCaseFlipperTransform alloc] init]];
    [result addObject:[[NWIOCryptoTransform alloc] init]];
    [result addObject:[[NWIODeflateTransform alloc] init]];
    [result addObject:[[NWIOHcodeTransform alloc] init]];
    [result addObject:[[NWIOZcodeTransform alloc] init]];
    return result;
}

@end
