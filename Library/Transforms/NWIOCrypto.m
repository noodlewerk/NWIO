//
//  NWIOCrypto.m
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

#import "NWIOCrypto.h"
#include <CommonCrypto/CommonCryptor.h>

static NSString * const NWIOStatusKey = @"status";

// TODO: feed encryption as much bytes as output can handle, instead of asserting on CCCryptorGetOutputLength

@implementation NWIOCryptoTransform {
    CCCryptorRef backwardCryptor;
    CCCryptorRef forwardCryptor;
}

@synthesize key, iv;


#pragma mark - Object life cycle

- (void)dealloc {
    [self resetBackward];
    [self resetForward];
}


#pragma mark - Error handling

- (NSError *)errorForStatus:(int)status {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInteger:status] forKey:NWIOStatusKey];
    return [NSError errorWithDomain:NSStringFromClass(self.class) code:status userInfo:info];
}


#pragma mark - NWIOTransform subclass

// TODO: add support for zero (NULL) buffers, like in NWIODeflate

// turns zip into bytes (inflate)
- (BOOL)transformBackwardFromBuffer:(const unsigned char *)fromBuffer fromLength:(NSUInteger)fromLength fromInc:(NSUInteger *)fromInc toBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    if (!backwardCryptor) {
        unsigned char keyBuffer[kCCKeySizeAES128];
        memset(keyBuffer, 0, sizeof(keyBuffer));
        memcpy(keyBuffer, key.bytes, key.length < sizeof(keyBuffer) ? key.length : sizeof(keyBuffer));
        unsigned char ivBuffer[kCCBlockSizeAES128];
        memset(ivBuffer, 0, sizeof(ivBuffer));
        memcpy(ivBuffer, iv.bytes, iv.length < sizeof(ivBuffer) ? iv.length : sizeof(ivBuffer));
        CCCryptorStatus status = CCCryptorCreate(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, keyBuffer, kCCKeySizeAES128, ivBuffer, &backwardCryptor);
        if (status != kCCSuccess) {
            if (error) {
                *error = [self errorForStatus:status];
            }
            backwardCryptor = NULL;
            return NO;
        }
    }
    NSAssert(CCCryptorGetOutputLength(backwardCryptor, fromLength, false) <= toLength, @"Should out fit: %i<=%i", CCCryptorGetOutputLength(backwardCryptor, fromLength, false), toLength);
    size_t dataOutMoved = 0;
    CCCryptorStatus status = CCCryptorUpdate(backwardCryptor, fromBuffer, fromLength, toBuffer, toLength, &dataOutMoved);
    if (status != kCCSuccess) {
        if (error) {
            *error = [self errorForStatus:status];
        }
        return NO;
    }
    NSAssert(dataOutMoved <= toLength, @"Should be within buffer length: %i<=%i", dataOutMoved, toLength);
    *fromInc = fromLength;
    *toInc = dataOutMoved;
    return YES;
}

// turns bytes into zip (deflate)
- (BOOL)transformForwardFromBuffer:(const unsigned char *)fromBuffer fromLength:(NSUInteger)fromLength fromInc:(NSUInteger *)fromInc toBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    if (!forwardCryptor) {
        unsigned char keyBuffer[kCCKeySizeAES128];
        memset(keyBuffer, 0, sizeof(keyBuffer));
        memcpy(keyBuffer, key.bytes, key.length < sizeof(keyBuffer) ? key.length : sizeof(keyBuffer));
        unsigned char ivBuffer[kCCBlockSizeAES128];
        memset(ivBuffer, 0, sizeof(ivBuffer));
        memcpy(ivBuffer, iv.bytes, iv.length < sizeof(ivBuffer) ? iv.length : sizeof(ivBuffer));
        CCCryptorStatus status = CCCryptorCreate(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, keyBuffer, kCCKeySizeAES128, ivBuffer, &forwardCryptor);
        if (status != kCCSuccess) {
            if (error) {
                *error = [self errorForStatus:status];
            }
            forwardCryptor = NULL;
            return NO;
        }
    }
    NSAssert(CCCryptorGetOutputLength(forwardCryptor, fromLength, false) <= toLength, @"Should out fit: %i<=%i", CCCryptorGetOutputLength(forwardCryptor, fromLength, false), toLength);
    size_t dataOutMoved = 0;
    CCCryptorStatus status = CCCryptorUpdate(forwardCryptor, fromBuffer, fromLength, toBuffer, toLength, &dataOutMoved);
    if (status != kCCSuccess) {
        if (error) {
            *error = [self errorForStatus:status];
        }
        return NO;
    }
    NSAssert(dataOutMoved <= toLength, @"Should be within buffer length: %i<=%i", dataOutMoved, toLength);
    *fromInc = fromLength;
    *toInc = dataOutMoved;
    return YES;
}

- (BOOL)flushBackwardToBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    if (!backwardCryptor) {
        *toInc = 0;
        return YES;
    }
    size_t dataOutMoved = 0;
    CCCryptorStatus status = CCCryptorFinal(backwardCryptor, toBuffer, toLength, &dataOutMoved);
    if (status != kCCSuccess) {
        if (error) {
            *error = [self errorForStatus:status];
        }
        return NO;
    }
    CCCryptorRelease(backwardCryptor); backwardCryptor = NULL;
    *toInc = dataOutMoved;
    return YES;
}

- (BOOL)flushForwardToBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error {
    if (!forwardCryptor) {
        *toInc = 0;
        return YES;
    }
    size_t dataOutMoved = 0;
    CCCryptorStatus status = CCCryptorFinal(forwardCryptor, toBuffer, toLength, &dataOutMoved);
    if (status != kCCSuccess) {
        if (error) {
            *error = [self errorForStatus:status];
        }
        return NO;
    }
    CCCryptorRelease(forwardCryptor); forwardCryptor = NULL;
    *toInc = dataOutMoved;
    return YES;
}

- (void)resetBackward {
    if (backwardCryptor) {
        CCCryptorRelease(backwardCryptor); backwardCryptor = NULL;
    }
}

- (void)resetForward {
    if (forwardCryptor) {
        CCCryptorRelease(forwardCryptor); forwardCryptor = NULL;
    }
}

@end



@implementation NWIOCryptoStream


#pragma mark - Object life cycle

- (id)initWithStream:(NWIOStream *)_stream {
    return [super initWithStream:_stream transform:[[NWIOCryptoTransform alloc] init]];
}

- (NSData *)key {
    return [(NWIOCryptoTransform *)self.transform key];
}

- (void)setKey:(NSData *)key {
    [(NWIOCryptoTransform *)self.transform setKey:key];
}

- (NSData *)iv {
    return [(NWIOCryptoTransform *)self.transform iv];
}

- (void)setIv:(NSData *)iv {
    [(NWIOCryptoTransform *)self.transform setKey:iv];
}

@end



@implementation NWIOCryptoAccess {
    void *startIV;
    void *blockBuffer;
}

@synthesize inputLength, outputLength, key, iv;

#pragma mark - Object life cycle

- (void)dealloc {
    if (startIV) {
        free(startIV); startIV = NULL;
    }
    if (blockBuffer) {
        free(blockBuffer); blockBuffer = NULL;
    }
}

#pragma mark - Access subclass

- (NSUInteger)read:(void *)buffer range:(NSRange)range {
    NSUInteger bufferLength = range.length;

    NSUInteger startBlock = range.location / kCCBlockSizeAES128;
    NSUInteger offsetInBlock = range.location % kCCBlockSizeAES128;

    BOOL readIV = startBlock > 0;

    NSUInteger startRange = readIV ? (startBlock - 1) * kCCBlockSizeAES128 : 0;
    NSUInteger minLength = readIV ? 2 * kCCBlockSizeAES128 : kCCBlockSizeAES128;

    const void *read = nil;
    NSUInteger readLength = [access readable:&read location:startRange];

    // make sure we have enough data to operate
    if (readLength < minLength) {
        NSAssert(NO, @"to few input bytes, %i<%i", readLength, minLength);
        return 0;
    }

    // prepare the intialization vector
    unsigned char ivBuffer[kCCBlockSizeAES128];
    if (readIV) {
        memcpy(ivBuffer, read, kCCBlockSizeAES128);
        read += kCCBlockSizeAES128;
        readLength -= kCCBlockSizeAES128;
    } else {
        memset(ivBuffer, 0, sizeof(ivBuffer));
        memcpy(ivBuffer, iv.bytes, iv.length < sizeof(ivBuffer) ? iv.length : sizeof(ivBuffer));
    }

    // prepare cryptor
    unsigned char keyBuffer[kCCKeySizeAES128];
    memset(keyBuffer, 0, sizeof(keyBuffer));
    memcpy(keyBuffer, key.bytes, key.length < sizeof(keyBuffer) ? key.length : sizeof(keyBuffer));
    CCCryptorRef crypto = nil;
    CCCryptorStatus status = CCCryptorCreate(kCCDecrypt, kCCAlgorithmAES128, 0, keyBuffer, kCCKeySizeAES128, ivBuffer, &crypto);
    if (status != kCCSuccess) NSAssert(NO, @"%i", status);

    // read the first block to handle offset in block
    if (offsetInBlock) {
        if (!blockBuffer) {
            blockBuffer = malloc(kCCBlockSizeAES128);
            NSAssert(blockBuffer != NULL, @"Should be allocated");
        }
        memset(blockBuffer, 0, kCCBlockSizeAES128);
        size_t moved = 0;
        CCCryptorStatus status = CCCryptorUpdate(crypto, read, kCCBlockSizeAES128, blockBuffer, kCCBlockSizeAES128, &moved);
        if (status != kCCSuccess) NSAssert(NO, @"%i", status);
        NSAssert(moved == kCCBlockSizeAES128, @"%i==kCCBlockSizeAES128", moved);
        NSAssert(readLength >= kCCBlockSizeAES128, @"");
        read += kCCBlockSizeAES128;
        readLength -= kCCBlockSizeAES128;
        NSUInteger l = kCCBlockSizeAES128 - offsetInBlock;
        if (l > bufferLength) {
            l = bufferLength;
        }
        memcpy(buffer, blockBuffer + offsetInBlock, l);
        buffer += l;
        bufferLength -= l;
    }

    NSUInteger ouptputBlockCount = bufferLength / kCCBlockSizeAES128;
    NSUInteger inputBlockCount = readLength / kCCBlockSizeAES128;
    NSUInteger blockCount = MIN(inputBlockCount, ouptputBlockCount);

    // read all complete blocks
    if (blockCount) {
        size_t moved = 0;
        CCCryptorStatus status = CCCryptorUpdate(crypto, read, blockCount * kCCBlockSizeAES128, buffer, blockCount * kCCBlockSizeAES128, &moved);
        if (status != kCCSuccess) NSAssert(NO, @"%i", status);
        NSAssert(moved <= readLength, @"%i<=%i", moved, readLength);
        NSAssert(moved <= bufferLength, @"%i<=%i", moved, bufferLength);
        NSAssert(moved % kCCBlockSizeAES128 == 0, @"%i %% kCCBlockSizeAES128==%i", moved, moved % kCCBlockSizeAES128);
        read += moved;
        readLength -= moved;
        buffer += moved;
        bufferLength -= moved;
    }

    // read leftovers
    if (bufferLength && readLength >= kCCBlockSizeAES128) {
        if (!blockBuffer) {
            blockBuffer = malloc(kCCBlockSizeAES128);
            NSAssert(blockBuffer != NULL, @"Should be allocated");
        }
        memset(blockBuffer, 0, kCCBlockSizeAES128);
        size_t moved = 0;
        CCCryptorStatus status = CCCryptorUpdate(crypto, read, kCCBlockSizeAES128, blockBuffer, kCCBlockSizeAES128, &moved);
        if (status != kCCSuccess) NSAssert(NO, @"%i", status);
        NSAssert(moved == kCCBlockSizeAES128, @"%i==kCCBlockSizeAES128", moved);
        NSAssert(readLength >= kCCBlockSizeAES128, @"");
        NSAssert(bufferLength < kCCBlockSizeAES128, @"");
        read += kCCBlockSizeAES128;
//        readLength -= kCCBlockSizeAES128;
        memcpy(buffer, blockBuffer, bufferLength);
//        buffer += bufferLength;
        bufferLength -= bufferLength;
    }

    NSAssert(range.length >= bufferLength, @"");
    return range.length - bufferLength;
}

- (NSUInteger)write:(const void *)buffer range:(NSRange)range {
    NSAssert(NO, @"Access write not supported by crypto.");
    return 0;
}

@end

