//
//  NWIOZcode.m
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

#import "NWIOZcode.h"


@implementation NWIOZcodeTransform {
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

static unsigned char isAlpha[256] = {
     NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO, 
     NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO, 
     NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO, 
    YES, YES, YES, YES, YES, YES, YES, YES, YES, YES,  NO,  NO,  NO,  NO,  NO,  NO,
     NO, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES,
    YES, YES, YES, YES, YES, YES, YES, YES, YES, YES,  NO,  NO,  NO,  NO,  NO,  NO, 
     NO, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES,
    YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES,  NO,  NO,  NO,  NO,  NO, 
     NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO, 
     NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO, 
     NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO, 
     NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO, 
     NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO, 
     NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO, 
     NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO, 
     NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO,  NO, 
};


#pragma mark - NWIOTransform subclass

// fully processes at least one of the buffers
- (BOOL)transformBackwardFromBuffer:(const unsigned char *)fromBuffer fromLength:(NSUInteger)fromLength fromInc:(NSUInteger *)fromInc toBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    const unsigned char *fromEnd = fromBuffer + fromLength;
    unsigned char *toEnd = toBuffer + toLength;
    for (unsigned char c = *fromBuffer; toBuffer < toEnd && fromBuffer < fromEnd; c = *(++fromBuffer)) {
        switch (backState) {
            case 0: {
                if (c == 'Z') {
                    // came across the escape character, so go in byte modus
                    backState++;
                } else {
                    *(toBuffer++) = c;
                }
            } break;
            case 1: {
                unsigned char d = toDec[c];
                if (d < XX) {
                    // this is the first of two, so let's keep it
                    backChar = d * 16;
                    backState++;
                } else {
                    // ignore byte mode
                    *(toBuffer++) = c;
                    backState = 0;
                }
            } break;
            case 2: {
                unsigned char d = toDec[c];
                if (d < XX) {
                    // we already had one part, let's add the other
                    *(toBuffer++) = backChar + d;
                } else {
                    // apparently single hex encoded
                    *(toBuffer++) = backChar;
                    // re-read current character
                    fromBuffer--;
                }
                backState = 0;
            } break;
        }
    }
    *fromInc = fromLength - (fromEnd - fromBuffer);
    *toInc = toLength - (toEnd - toBuffer);
    return YES;
}

- (BOOL)transformForwardFromBuffer:(const unsigned char *)fromBuffer fromLength:(NSUInteger)fromLength fromInc:(NSUInteger *)fromInc toBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    const unsigned char *fromEnd = fromBuffer + fromLength;
    unsigned char *toEnd = toBuffer + toLength;
    for (; toBuffer < toEnd && fromBuffer < fromEnd; toBuffer++) {
        switch (forState) {
            case 0:
                forChar = *(fromBuffer++);
                if (isAlpha[forChar]) {
                    // it's a direct character, so just write it
                    *toBuffer = forChar;
                    forState = 0;
                } else {
                    *toBuffer = 'Z';
                    forState++;
                }
                break;
            case 1:
                *toBuffer = toHex[(forChar >> 4) & 0xF];
                forState++;
                break;
            case 2:
                *toBuffer = toHex[forChar & 0xF];
                forState = 0;
                break;
        }
    }
    *fromInc = fromLength - (fromEnd - fromBuffer);
    *toInc = toLength - (toEnd - toBuffer);
    return YES;
}

- (BOOL)flushBackwardToBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    if (backState == 2 && toLength) {
        // we assume next character will be a zero
        *toBuffer = backChar;
        (*toInc)++;
        backState = 0;
    }
    return backState == 0;
}

- (BOOL)flushForwardToBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    if (forState == 1 && toLength) {
        *(toBuffer++) = toHex[(forChar >> 4) & 0xF];
        (*toInc)++;
        forState++;
        toLength--;
    }
    if (forState == 2 && toLength) {
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


@implementation NWIOZcodeStream

- (id)initWithStream:(NWIOStream *)_stream {
    return [super initWithStream:_stream transform:[[NWIOZcodeTransform alloc] init]];
}

@end