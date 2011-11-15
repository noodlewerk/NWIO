//
//  NWIOCaseFlipper.m
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

#import "NWIOCaseFlipper.h"


@implementation NWIOCaseFlipperTransform


#pragma mark - Flip that case

+ (void)flipBuffer:(const unsigned char *)fromBuffer toBuffer:(unsigned char *)toBuffer length:(NSUInteger)length {
    for (NSUInteger i = 0; i < length; i++) {
        unsigned char c = fromBuffer[i];
        if (c >= 'a' && c <= 'z') {
            toBuffer[i] = c - 32;
        } else if (c >= 'A' && c <= 'Z') {
            toBuffer[i] = c + 32;
        } else {
            toBuffer[i] = c;
        }
    }
}


#pragma mark - NWIOTransform subclass

- (BOOL)transformBackwardFromBuffer:(const unsigned char *)fromBuffer fromLength:(NSUInteger)fromLength fromInc:(NSUInteger *)fromInc toBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    NSUInteger length = fromLength < toLength ? fromLength : toLength;
    [NWIOCaseFlipperTransform flipBuffer:fromBuffer toBuffer:toBuffer length:length];
    *fromInc = length;
    *toInc = length;
    return YES;
}

- (BOOL)transformForwardFromBuffer:(const unsigned char *)fromBuffer fromLength:(NSUInteger)fromLength fromInc:(NSUInteger *)fromInc toBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    NSUInteger length = fromLength < toLength ? fromLength : toLength;
    [NWIOCaseFlipperTransform flipBuffer:fromBuffer toBuffer:toBuffer length:length];
    *fromInc = length;
    *toInc = length;
    return YES;
}

- (BOOL)flushBackwardToBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    // no need for flushing
    return YES;
}

- (BOOL)flushForwardToBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    // no need for flushing
    return YES;
}

- (void)resetBackward {
    // no need for reset
}

- (void)resetForward {
    // no need for reset
}

@end



@implementation NWIOCaseFlipperStream

- (id)initWithStream:(NWIOStream *)_stream {
    return [super initWithStream:_stream transform:[[NWIOCaseFlipperTransform alloc] init]];
}

@end
