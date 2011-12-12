//
//  NWIOBase64.m
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

#import "NWIOBase64.h"


@implementation NWIOBase64Transform {
    unsigned char backState;
    unsigned char backChar;
    unsigned char forState;
    unsigned char forChar;
}


#pragma mark - NWIOTransform subclass

static unsigned char toBase[65] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

#define XX 64

static unsigned char toDec[256] = {
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 62, XX, XX, XX, 63, 
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, XX, XX, XX, XX, XX, XX, 
    XX,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, XX, XX, XX, XX, XX, 
    XX, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, 
};

// fully processes at least one of the buffers
- (BOOL)transformBackwardFromBuffer:(const unsigned char *)fromBuffer fromLength:(NSUInteger)fromLength fromInc:(NSUInteger *)fromInc toBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    const unsigned char *fromEnd = fromBuffer + fromLength;
    unsigned char *toEnd = toBuffer + toLength;
    for (; toBuffer < toEnd && fromBuffer < fromEnd; fromBuffer++) {
        unsigned char d = toDec[*fromBuffer];
        if (d < XX) {
            switch (backState) {
                case 0:
                    backChar = d << 2;
                    backState++;
                    break;
                case 1:
                    *(toBuffer++) = backChar + (d >> 4);
                    backChar = d << 4;
                    backState++;
                    break;
                case 2:
                    *(toBuffer++) = backChar + (d >> 2);
                    backChar = d << 6;
                    backState++;
                    break;
                case 3:
                    *(toBuffer++) = backChar + d;
                    backChar = 0;
                    backState = 0;
                    break;
            }
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
                *toBuffer = toBase[(*fromBuffer & 0xFC) >> 2];
                forChar = (*fromBuffer & 0x03) << 4;
                fromBuffer++;
                forState++;
                break;
            case 1:
                *toBuffer = toBase[forChar | ((*fromBuffer & 0xF0) >> 4)];
                forChar = (*fromBuffer & 0x0F) << 2;
                fromBuffer++;
                forState++;
                break;
            case 2:
                *toBuffer = toBase[forChar | ((*fromBuffer & 0xC0) >> 6)];
                forChar = *fromBuffer & 0x3F;
                fromBuffer++;
                forState++;
                break;
            case 3:
                *toBuffer = toBase[forChar];
                forChar = 0;
                forState = 0;
                break;
        }
    }
    *fromInc = fromLength - (fromEnd - fromBuffer);
    *toInc = toLength - (toEnd - toBuffer);
    return YES;
}

- (BOOL)flushBackwardToBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    if (backChar && backState && toLength) {
        // we assume next character will be a zero
        *toBuffer = backChar;
        (*toInc)++;
        backState = 0;
    }
    return backState == 0;
}

- (BOOL)flushForwardToBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    if (forChar && forState && toLength) {
        *(toBuffer++) = toBase[forChar];
        (*toInc)++;
        forState = ++forState % 4;
        toLength--;
        forChar = 0;
    }
    while (forState && toLength) {
        *(toBuffer++) = '=';
        (*toInc)++;
        forState = ++forState % 4;
        toLength--;
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


@implementation NWIOBase64Stream

- (id)initWithStream:(NWIOStream *)_stream {
    return [super initWithStream:_stream transform:[[NWIOBase64Transform alloc] init]];
}

@end
