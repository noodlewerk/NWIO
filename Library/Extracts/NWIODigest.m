//
//  NWIODigest.m
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

#import "NWIODigest.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NWIODigestExtract {
    void *context;
}

@synthesize method;


#pragma mark - Object life cycle

- (id)initWithStream:(NWIOStream *)_stream method:(NWIODigestMethod)_method {
    self = [super init];
    if (self) {
        method = _method;
    }
    return self;
}

- (void)dealloc {
    if (context) {
        free(context); context = NULL;
    }
}


#pragma mark - Switches to make this class digest method independent

#define NWIODigestContextSizeCase(__a) NWIODigestMethod##__a: return sizeof(CC_##__a##_CTX); break
- (NSUInteger)contextSize {
    switch (method) {
        case NWIODigestContextSizeCase(MD2);
        case NWIODigestContextSizeCase(MD4);
        case NWIODigestContextSizeCase(MD5);
        case NWIODigestContextSizeCase(SHA1);
        case NWIODigestContextSizeCase(SHA256);
        case NWIODigestContextSizeCase(SHA512);
    }
    return 0;
}

#define NWIODigestSizeCase(__a) NWIODigestMethod##__a: return CC_##__a##_DIGEST_LENGTH; break
- (NSUInteger)digestSize {
    switch (method) {
        case NWIODigestSizeCase(MD2);
        case NWIODigestSizeCase(MD4);
        case NWIODigestSizeCase(MD5);
        case NWIODigestSizeCase(SHA1);
        case NWIODigestSizeCase(SHA256);
        case NWIODigestSizeCase(SHA512);
    }
    return 0;
}

#define NWIODigestInitCase(__a) NWIODigestMethod##__a: CC_##__a##_Init(c); break
- (void)initContext:(void *)c {
    switch (method) {
        case NWIODigestInitCase(MD2);
        case NWIODigestInitCase(MD4);
        case NWIODigestInitCase(MD5);
        case NWIODigestInitCase(SHA1);
        case NWIODigestInitCase(SHA256);
        case NWIODigestInitCase(SHA512);
    }
}

#define NWIODigestUpdateCase(__a) NWIODigestMethod##__a: CC_##__a##_Update(c, data, len); break
- (void)updateContext:(void *)c data:(const void *)data len:(CC_LONG)len {
    switch (method) {
        case NWIODigestUpdateCase(MD2);
        case NWIODigestUpdateCase(MD4);
        case NWIODigestUpdateCase(MD5);
        case NWIODigestUpdateCase(SHA1);
        case NWIODigestUpdateCase(SHA256);
        case NWIODigestUpdateCase(SHA512);
    }
}

#define NWIODigestFinalCase(__a) NWIODigestMethod##__a: CC_##__a##_Final(md, c); break
- (void)finalContext:(void *)c md:(unsigned char *)md {
    switch (method) {
        case NWIODigestFinalCase(MD2);
        case NWIODigestFinalCase(MD4);
        case NWIODigestFinalCase(MD5);
        case NWIODigestFinalCase(SHA1);
        case NWIODigestFinalCase(SHA256);
        case NWIODigestFinalCase(SHA512);
    }
}


#pragma mark - Digest

- (NSData *)digest {
    if (context) {
        // branch context
        NSUInteger contextSize = [self contextSize];
        void *c = malloc(contextSize);
        memcpy(c, context, contextSize);
        // provide digest buffer
        NSUInteger digestSize = [self digestSize];
        unsigned char *md = malloc(digestSize);
        memset(md, 0x0, digestSize);
        // finish digesting
        [self finalContext:c md:md];
        free(c);
        NSData *result = [NSData dataWithBytes:md length:digestSize];
        free(md);
        return result;
    }
    return nil;
}


#pragma mark - NWIOStream subclass

- (void)extractFrom:(const unsigned char *)buffer length:(NSUInteger)length {
    if (!context) {
        context = malloc([self contextSize]);
        [self initContext:context];
    }
    if (buffer && length) {
        [self updateContext:context data:buffer len:length];
    }
}

@end


@implementation NWIODigestStream

- (id)initWithStream:(NWIOStream *)_stream {
    return [super initWithStream:_stream inputExtract:[[NWIODigestExtract alloc] init] outputExtract:[[NWIODigestExtract alloc] init]];
}

- (NWIODigestMethod)inputMethod {
    return [(NWIODigestExtract *)self.inputExtract method];
}

- (NWIODigestMethod)outputMethod {
    return [(NWIODigestExtract *)self.outputExtract method];
}

- (void)setInputMethod:(NWIODigestMethod)method {
    return [(NWIODigestExtract *)self.inputExtract setMethod:method];
}

- (void)setOutputMethod:(NWIODigestMethod)method {
    return [(NWIODigestExtract *)self.outputExtract setMethod:method];
}

- (NSData *)inputDigest {
    return [(NWIODigestExtract *)self.inputExtract digest];
}

- (NSData *)outputDigest {
    return [(NWIODigestExtract *)self.outputExtract digest];
}

@end
