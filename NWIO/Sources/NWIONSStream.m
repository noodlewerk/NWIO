//
//  NWIONSStream.m
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

#import "NWIONSStream.h"


@implementation NWIONSStream {
    BOOL forceUseRead;
    NSUInteger readError;
    NSUInteger writeError;
}

@synthesize input, output;


#pragma mark - Object life cycle

- (id)initWithInput:(NSInputStream *)_input output:(NSOutputStream *)_output {
    self = [super init];
    if (self) {
        input = _input;
        output = _output;
    }
    return self;
}

- (id)initWithInput:(NSInputStream *)_input {
    return [self initWithInput:_input output:nil];
}

- (id)initWithOutput:(NSOutputStream *)_output {
    return [self initWithInput:nil output:_output];
}

- (id)initWithInputURL:(NSURL *)inputURL outputURL:(NSURL *)outputURL append:(BOOL)append {
    NSInputStream *_input = nil;
    if (inputURL) {
        _input = [NSInputStream inputStreamWithURL:inputURL];
        [_input open];
    }
    NSOutputStream *_output = nil;
    if (outputURL) {
        _output = [NSOutputStream outputStreamWithURL:outputURL append:append];
        [_output open];
    }
    return [self initWithInput:_input output:_output];
}

- (id)initWithInputURL:(NSURL *)inputURL {
    return [self initWithInputURL:inputURL outputURL:nil append:NO];
}

- (id)initWithOutputURL:(NSURL *)outputURL append:(BOOL)append {
    return [self initWithInputURL:nil outputURL:outputURL append:append];
}

- (id)initWithOutputURL:(NSURL *)outputURL {
    return [self initWithInputURL:nil outputURL:outputURL append:NO];
}


#pragma mark - NWIOStream subclass

- (NSUInteger)read:(void *)buffer length:(NSUInteger)length {
    if (buffer) {
        NSInteger result = [input read:buffer maxLength:length];
        if (result >= 0) {
            return (NSUInteger)result;
        }
        readError = (NSUInteger)-result;
    }
    return 0;
}

- (NSUInteger)readable:(const void **)buffer {
    if (forceUseRead) {
        return [super readable:buffer];
    }
    NSUInteger result = 0;
    if (buffer) {
        if (![input getBuffer:(uint8_t **)buffer length:&result]) {
            // get buffer doesn't seem to work atm, try active reading
            result = [super readable:buffer];
            if (result) {
                // apparently, there is something to read there, assume getBuffer is not supported
                forceUseRead = YES;
            }
        }
    }
    return result;
}

- (NSUInteger)write:(const void *)buffer length:(NSUInteger)length {
    if (buffer) {
        NSInteger result = [output write:buffer maxLength:length];
        if (result >= 0) {
            return (NSUInteger)result;
        }
        writeError = (NSUInteger)-result;
    }
    return 0;
}


#pragma mark - Controls

- (BOOL)hasReadBytesAvailable {
    if ([input hasBytesAvailable]) {
        return YES;
    }
    return [super hasReadBytesAvailable];
}

- (BOOL)hasWriteSpaceAvailable {
    if ([output hasSpaceAvailable]) {
        return YES;
    }
    return [super hasWriteSpaceAvailable];
}

- (void)rewindRead {
    NSAssert(NO, @"rewindRead not supported");
}

- (void)rewindWrite {
    NSAssert(NO, @"rewindWrite not supported");
}

- (void)closeRead {
    // super doesn't need flushing
    // no support for rewind, so we close now
    [input close];
}

- (void)closeWrite {
    [super closeWrite];
    // no support for rewind, so we close now
    [output close];
}

- (NSError *)readError {
    NSError *result = [input streamError];
    if (!result) {
        result = [super readError];
    }
    if (!result && readError) {
        result = [NSError errorWithDomain:@"NWIONSStream" code:readError userInfo:nil];
    }
    return result;
}

- (NSError *)writeError {
    NSError *result = [output streamError];
    if (!result) {
        result = [super writeError];
    }
    if (!result && writeError) {
        result = [NSError errorWithDomain:@"NWIONSStream" code:writeError userInfo:nil];
    }
    return result;
}

- (void)sever {
    [super sever];
    input = nil;
    output = nil;
}

@end


@implementation NWIOInputStream {
    NSInputStream *decoy;
}

@synthesize stream;


#pragma mark - Object life cycle

- (id)initWithStream:(NWIOStream *)_stream {
    self = [super init];
    if (self) {
        stream = _stream;
        decoy = [[NSInputStream alloc] initWithData:[NSData dataWithBytes:"!" length:1]];
    }
    return self;
}


#pragma mark - Stream

// Read decoy to end of stream
- (void)readDecoy {
    uint8_t buffer[2];
    [decoy read:buffer maxLength:2];
}


#pragma mark - NSInputStream subclass

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)length {
    NSUInteger result = [stream read:buffer length:length];
    if (result == 0 && [stream hasReadEnded]) {
        // TODO: handle errors
        [self readDecoy];
    }
    return result;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)length {
    *length = [stream readable:(const void **)buffer];
    if (*length == 0 && [stream hasReadEnded]) {
        // TODO: handle errors
        [self readDecoy];
    }
    return YES;
}

- (BOOL)hasBytesAvailable {
    // TODO: test what happens with read=0 while [stream hasReadBytesAvailable]=YES
    return YES;
}


#pragma mark - NSStream subclass

- (void)open {
    [decoy open];
//    [stream openRead];
}

- (void)close {
    [stream closeRead];
    [decoy close];
     stream = nil;
}

- (id)delegate {
    return [decoy delegate];
}

- (void)setDelegate:(id)delegate {
    [decoy setDelegate:delegate];
}

- (id)propertyForKey:(NSString *)key {
    return [decoy propertyForKey:key];
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key {
    return [decoy setProperty:property forKey:key];
}

- (void)scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode {
    [decoy scheduleInRunLoop:runLoop forMode:mode];
}

- (void)removeFromRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode {
    [decoy removeFromRunLoop:runLoop forMode:mode];
}

- (NSStreamStatus)streamStatus {
    return [decoy streamStatus];
}

- (NSError *)streamError {
    return [decoy streamError];
}


#pragma mark - Forwarding

+ (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:NSInputStream.class];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:decoy];
}

+ (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSInputStream methodSignatureForSelector:selector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [decoy methodSignatureForSelector:selector];
}

@end



@implementation NWIOOutputStream {
    NSOutputStream *decoy;
    uint8_t decoyBuffer[1];
}

@synthesize stream;


#pragma mark - Object life cycle

- (id)initWithStream:(NWIOStream *)_stream {
    self = [super init];
    if (self) {
        stream = _stream;
        decoy = [[NSOutputStream alloc] initToBuffer:decoyBuffer capacity:1];
    }
    return self;
}


#pragma mark - Stream

// Write decoy to end of stream
- (void)writeDecoy {
    [decoy write:(const uint8_t *)"!!" maxLength:2];
}


#pragma mark - NSOutputStream subclass

- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)length {
    return [stream write:buffer length:length];
//    if (result == NWIOCodeEndOfStream) {
//        [self writeDecoy];
}

- (BOOL)hasSpaceAvailable {
    return [stream hasWriteSpaceAvailable];
}


#pragma mark - NSStream subclass

- (void)open {
    [decoy open];
//    [stream openWrite];
}

- (void)close {
    [decoy close];
    [stream closeWrite];
     stream = nil;
}

- (id)delegate {
    return [decoy delegate];
}

- (void)setDelegate:(id)delegate {
    [decoy setDelegate:delegate];
}

- (id)propertyForKey:(NSString *)key {
    return [decoy propertyForKey:key];
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key {
    return [decoy setProperty:property forKey:key];
}

- (void)scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode {
    [decoy scheduleInRunLoop:runLoop forMode:mode];
}

- (void)removeFromRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode {
    [decoy removeFromRunLoop:runLoop forMode:mode];
}

- (NSStreamStatus)streamStatus {
    return [decoy streamStatus];
}

- (NSError *)streamError {
    return [decoy streamError];
}


#pragma mark - Forwarding

+ (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:NSOutputStream.class];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:decoy];
}

+ (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSOutputStream methodSignatureForSelector:selector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [decoy methodSignatureForSelector:selector];
}

@end
