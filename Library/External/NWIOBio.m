//
//  NWIOBio.m
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

#import "NWIOBio.h"

int const NWIOBioErrorCode = -1;


@implementation NWIOBioStream

@synthesize bio, owner;


#pragma mark - Object life cycle

- (id)initWithBio:(BIO *)_bio owner:(id)_owner {
    self = [super init];
    if (self) {
        bio = _bio;
        owner = _owner;
    }
    return self;
}

- (id)initWithBio:(BIO *)_bio {
    return [self initWithBio:_bio owner:nil];
}

- (void)cleanup {
    if (!owner && bio) {
        BIO_free_all(bio);
    }
    bio = NULL;
    owner = nil;
}

- (void)dealloc {
    [self cleanup];
}


#pragma mark - NWIOStream subclass

- (NSUInteger)read:(void *)buffer length:(NSUInteger)length {
    if (bio) {
        return BIO_read(bio, buffer, length);
    }
    return 0;
}

- (NSUInteger)write:(const void *)buffer length:(NSUInteger)length {
    if (bio) {
        return BIO_write(bio, buffer, length);
    }
    return 0;
}


#pragma mark - Controls

- (BOOL)hasReadBytesAvailable {
    // TODO: does BIO support this?
    // Default to NO so we stop on 0 read
    return NO;
//    return [super hasReadBytesAvailable];
}

- (void)closeRead {
    // TODO: does BIO support this?
}

- (void)closeWrite {
    [super closeWrite];
    if (bio) {
        if (BIO_flush(bio)){}
    }
}

- (void)rewindRead {
    // TODO: does BIO support this?
}

- (void)rewindWrite {
    // TODO: does BIO support this?
}

- (NSError *)readError {
    // TODO: does BIO support this?
    return nil;
}

- (NSError *)writeError {
    // TODO: does BIO support this?
    return nil;
}

- (void)sever {
    [super sever];
    [self cleanup];
}

@end


#pragma mark - BIO Operations

static int NWIOBioWrite(BIO *bio, const char *buffer, int length) {
    if (!bio || !bio->ptr) {
        return NWIOBioErrorCode;
    }
    return [(__bridge NWIOStream *)bio->ptr write:buffer length:length];
}

static int NWIOBioRead(BIO *bio, char *buffer, int length) {
    if (!bio || !bio->ptr) {
        return NWIOBioErrorCode;
    }
    return [(__bridge NWIOStream *)bio->ptr read:buffer length:length];
}

static long NWIOBioCtrl(BIO *bio, int cmd, long num, void *ptr) {
    switch (cmd) {
        case BIO_CTRL_PUSH:
        case BIO_CTRL_POP:
            return 0;
        default: {
            return 0;
        }
    }
}

static int NWIOBioCreate(BIO *bio) {
    bio->init = 1;
    bio->shutdown = 1;
    bio->num = 0;
    bio->ptr = NULL;
    bio->flags = 0;
    return 1;
}

static int NWIOBioDestroy(BIO *bio) {
    if (!bio || !bio->ptr) {
        return 0;
    }
    bio->ptr = NULL;
    bio->init = 0;
    bio->flags = 0;
    return 1;
}

static BIO_METHOD NWIOBioMethod = {
    BIO_TYPE_SOURCE_SINK,
    "NWIOBio",
    NWIOBioWrite,
    NWIOBioRead,
    NULL,
    NULL,
    NWIOBioCtrl,
    NWIOBioCreate,
    NWIOBioDestroy
};


#pragma mark - BIO setup

static BIO_METHOD *BIO_s_NWIO() {
    return &NWIOBioMethod;
}

BIO *NWIOBioCreateWithStream(NWIOStream *stream) {
    if (!stream) {
        return NULL;
    }
    BIO *result = BIO_new(BIO_s_NWIO());
    if (!result) {
        return NULL;
    }
    result->ptr = (__bridge_retained void *)(stream);
    result->num = 0;
    return result;
}
