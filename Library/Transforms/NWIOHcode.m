//
//  NWIOHcode.m
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

#import "NWIOHcode.h"


static NSUInteger const NWIOBlockSize = 8;


@implementation NWIOHcodeTransform {
    unsigned char backState;
    unsigned char backChar;
    unsigned char forState;
    unsigned char forChar;
}

static unsigned char toHex[65] = "0123456789ABCDEFG";

#define XX 16

static unsigned char toDec[256] = {
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX,
     0,  1,  2,  3,  4,  5,  6,  7,  8,  9, XX, XX, XX, XX, XX, XX, 
    XX, 10, 11, 12, 13, 14, 15, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, 10, 11, 12, 13, 14, 15, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
};


#pragma mark - NWIOTransform subclass

// turns hex into bytes, '7768656E' -> 'when'
- (BOOL)transformBackwardFromBuffer:(const unsigned char *)fromBuffer fromLength:(NSUInteger)fromLength fromInc:(NSUInteger *)fromInc toBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    const unsigned char *fromEnd = fromBuffer + fromLength;
    unsigned char *toEnd = toBuffer + toLength;
    for (unsigned char c = *fromBuffer; toBuffer < toEnd && fromBuffer < fromEnd; c = *(++fromBuffer)) {
        unsigned char d = toDec[c];
        if (d < XX) {
            if (backState) {
                // we already had one part, let's add the other
                *(toBuffer++) = backChar + d;
                backState = 0;
            } else {
                // this is the first of two, so let's keep it
                backChar = d * 16;
                backState++;
            }
        }
    }
    *fromInc = fromLength - (fromEnd - fromBuffer);
    *toInc = toLength - (toEnd - toBuffer);
    return YES;
}

// turns bytes into hex, 'when' -> '7768656E'
- (BOOL)transformForwardFromBuffer:(const unsigned char *)fromBuffer fromLength:(NSUInteger)fromLength fromInc:(NSUInteger *)fromInc toBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    const unsigned char *fromEnd = fromBuffer + fromLength;
    unsigned char *toEnd = toBuffer + toLength;
    for (; toBuffer < toEnd && (fromBuffer < fromEnd || forState % 2); toBuffer++) {
        if (forState == NWIOBlockSize) {
            // add a space every 8 characters
            *toBuffer = ' ';
            forState = 0;
        } else if(forState % 2) {
            // write lower half
            *toBuffer = toHex[forChar & 0xF];
            forState++;
        } else {
            // read new chacter to encode
            forChar = *(fromBuffer++);
            // write upper half
            *toBuffer = toHex[(forChar >> 4) & 0xF];
            forState++;
        }
    }
    *fromInc = fromLength - (fromEnd - fromBuffer);
    *toInc = toLength - (toEnd - toBuffer);
    return YES;
}

- (BOOL)flushBackwardToBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    // backState 0: no information about the character
    if (backState && toLength) {
        // case 1: we assume next character will be a zero
        *toBuffer = backChar;
        (*toInc)++;
        backState = 0;
    }
    return backState == 0;
}

- (BOOL)flushForwardToBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    // forState even: no information nor need
    if(forState % 2 && toLength) {
        *toBuffer = toHex[forChar & 0xF];
        (*toInc)++;
        forState = 0;
    }
    return forState == 0;
}

- (void)resetBackward {
    backState = 0;
}

- (void)resetForward {
    forState = 0;
}

@end



@implementation NWIOHcodeStream

- (id)initWithStream:(NWIOStream *)_stream {
    return [super initWithStream:_stream transform:[[NWIOHcodeTransform alloc] init]];
}

@end