//
//  NWIOTestTools.m
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

#import "NWIOTestTools.h"


#define IS_HEX(_a) (((_a)>='0'&&(_a)<='9')||((_a)>='A'&&(_a)<='F')||((_a)>='a'&&(_a)<='f'))
#define TO_NUM(_a) ((_a)<='9'?(_a)-'0':((_a)<='Z'?(_a)-('A'-10):((_a)<='z'?(_a)-('a'-10):0)))

@implementation NWIOTestTools

+ (NSData *)dataFromHexString:(NSString *)hexString {
    NSAssert(hexString.length % 2 == 0, @"Hex should have even length");
    NSUInteger bufferLength = hexString.length / 2;
    unsigned char *buffer = malloc(bufferLength);
    memset(buffer, 0, bufferLength);
    for (NSUInteger i = 0; i < hexString.length; i++) {
        unsigned char c = [hexString characterAtIndex:i];
        NSAssert(IS_HEX(c), @"Should be in 0..F: %c", c);
        buffer[i / 2] = buffer[i / 2] * 16 + TO_NUM(c);
    }
    return [NSData dataWithBytesNoCopy:buffer length:bufferLength];
}

@end
