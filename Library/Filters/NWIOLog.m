//
//  NWIOLog.m
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

#import "NWIOLog.h"

// to add logging of characters in 0x00-0x20 range
//#define LOG_CONTROL_CHARS

static unsigned char toPrint[256] = 
    "                                "
    " !\"#$%&'()*+,-./0123456789:;<=>?"
    "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_"
    "`abcdefghijklmnopqrstuvwxyz{|}~ "
    "                                "
    "                                "
    "                                "
    "                                ";

@interface NWIOLogBase : NSObject
@end

@implementation NWIOLogBase

static NSUInteger const NWIOLogBufferWidth = 16;

+ (NSString *)formatBuffer:(const void *)buffer length:(NSUInteger)length {
    if (!buffer) {
        return nil;
    }
    const unsigned char *b = (const unsigned char *)buffer;
    NSMutableString *result = [NSMutableString stringWithCapacity:length * 4];
    for (NSUInteger i = 0; i < length; i += NWIOLogBufferWidth) {
        [result appendFormat:@"\n%6i   ", i];
        for (NSUInteger j = i, count = i + NWIOLogBufferWidth; j < count; j++) {
            if (j < length) {
                [result appendFormat:@"%02X ", b[j]];
            } else {
                [result appendString:@"   "];
            }
            if (j % 4 == 3) {
                [result appendString:@" "];
            }
        }
        [result appendString:@"  "];
        for (NSUInteger j = i, count = MIN(i + NWIOLogBufferWidth, length); j < count; j++) {
            unsigned char c = b[j];
#ifdef LOG_CONTROL_CHARS
            if (c <= 0x20) {
                unichar d = 0x2400 + c;
                [result appendString:[NSString stringWithCharacters:&d length:1]];
            } else if (c == 0x7F) {
                unichar d = 0x2421;
                [result appendString:[NSString stringWithCharacters:&d length:1]];
            } else
#endif
            if (c != '%') {
                [result appendFormat:@"%c", toPrint[c]];
            } else {
                // for some reason '%' is not propery interpreted
                [result appendString:@"%%"];
            }
        }
    }
    return result;
}

+ (void)logWithBlock:(void(^)(NSString *))logBlock tag:(NSString *)tag line:(NSString *)line {
    if (line.length) {
        if (tag) {
            line = [NSString stringWithFormat:@"[%@] %@", tag, line];
        }
        if (logBlock) {
            logBlock(line);
        } else {
            NSLog(@"%@", line);
        }
    }
}

+ (void)logWithBlock:(void(^)(NSString *))logBlock tag:(NSString *)tag operation:(NSString *)operation buffer:(const void *)buffer length:(NSUInteger)length {
    NSString *line = nil;
    if (length && buffer) {
        line = [NSString stringWithFormat:@"%@ %i bytes:%@", operation, length, [self formatBuffer:buffer length:length]];
    } else if(length) {
        line = [NSString stringWithFormat:@"%@ %i skipped", operation, length];
    } else {
        line = [NSString stringWithFormat:@"%@ zero bytes", operation];
    }
    [self logWithBlock:logBlock tag:tag line:line];
}

+ (void)logWithBlock:(void(^)(NSString *))logBlock tag:(NSString *)tag control:(id)control result:(id)result{
    NSString *line = nil;
    if (result) {
        line = [NSString stringWithFormat:@"%@ = %@", [control description], [result description]];
    } else {
        line = [NSString stringWithFormat:@"%@", [control description]];
    }
    [self logWithBlock:logBlock tag:tag line:line];
}

@end


@implementation NWIOLogStream {
    void *writableBuffer;
    NSUInteger writableLength;
}

@synthesize logBlock, tag;


#pragma mark - NWIOStream subclass

- (NSUInteger)read:(void *)buffer length:(NSUInteger)length {
    NSUInteger result = [super read:buffer length:length];
    [NWIOLogBase logWithBlock:logBlock tag:tag operation:[NSString stringWithFormat:@"read(%i)", length] buffer:buffer length:result];
    return result;
}

- (NSUInteger)readable:(const void **)buffer {
    NSUInteger result = [super readable:buffer];
    [NWIOLogBase logWithBlock:logBlock tag:tag operation:@"readable" buffer:buffer ? *buffer : NULL length:result];
    return result;
}

- (NSUInteger)write:(const void *)buffer length:(NSUInteger)length {
    NSUInteger result = [super write:buffer length:length];
    [NWIOLogBase logWithBlock:logBlock tag:tag operation:[NSString stringWithFormat:@"write(%i)", length] buffer:buffer length:result];
    return result;
}

- (NSUInteger)writable:(void **)buffer {
    NSUInteger result = [super writable:buffer];
    [NWIOLogBase logWithBlock:logBlock tag:tag operation:[NSString stringWithFormat:@"writable(%i), previous", result] buffer:writableBuffer length:writableLength];
    writableBuffer = *buffer;
    writableLength = result;
    return result;
}

- (void)unwritable:(NSUInteger)length {
    [super unwritable:length];
    [NWIOLogBase logWithBlock:logBlock tag:tag operation:[NSString stringWithFormat:@"unwritable(%i), previous", length] buffer:writableBuffer length:writableLength >= length ? writableLength - length : 0];
    writableBuffer = NULL;
    writableLength = 0;
}


#pragma mark - Controls

- (BOOL)hasReadBytesAvailable {
    BOOL result = [super hasReadBytesAvailable];
    [NWIOLogBase logWithBlock:logBlock tag:tag control:@"hasReadBytesAvailable" result:[NSNumber numberWithBool:result]];
    return result;
}

- (BOOL)hasWriteSpaceAvailable {
    BOOL result = [super hasWriteSpaceAvailable];
    [NWIOLogBase logWithBlock:logBlock tag:tag control:@"hasWriteSpaceAvailable" result:[NSNumber numberWithBool:result]];
    return result;
}

- (void)rewindRead {
    [NWIOLogBase logWithBlock:logBlock tag:tag control:@"rewindRead" result:0];
    [super rewindRead];
}

- (void)rewindWrite {
    [NWIOLogBase logWithBlock:logBlock tag:tag control:@"rewindWrite" result:0];
    [super rewindWrite];
}

- (NSError *)readError {
    NSError *result = [super readError];
    [NWIOLogBase logWithBlock:logBlock tag:tag control:@"readError" result:result];
    return result;
}

- (NSError *)writeError {
    NSError *result = [super writeError];
    [NWIOLogBase logWithBlock:logBlock tag:tag control:@"writeError" result:result];
    return result;
}

- (void)closeRead {
    [NWIOLogBase logWithBlock:logBlock tag:tag control:@"closeRead" result:0];
    [super closeRead];
}

- (void)closeWrite {
    [NWIOLogBase logWithBlock:logBlock tag:tag control:@"closeWrite" result:0];
    [super closeWrite];
}

- (void)sever {
    [NWIOLogBase logWithBlock:logBlock tag:tag control:@"sever" result:0];
    [super sever];
}

- (id)control:(id)control {
    id result = [super control:control];
    [NWIOLogBase logWithBlock:logBlock tag:tag control:control result:result];
    return result;
}

@end


@implementation NWIOLogAccess {
    void *writableBuffer;
    NSUInteger writableLength;
}

@synthesize logBlock, tag;


#pragma mark - NWIOAccess subclass

- (NSUInteger)read:(void *)buffer range:(NSRange)range {
    NSUInteger result = [super read:buffer range:range];
    [NWIOLogBase logWithBlock:logBlock tag:tag operation:[NSString stringWithFormat:@"read(%i,%i)", range.location, range.length] buffer:buffer length:result];
    return result;
}

- (NSUInteger)readable:(const void **)buffer location:(NSUInteger)location {
    NSUInteger result = [super readable:buffer location:location];
    [NWIOLogBase logWithBlock:logBlock tag:tag operation:[NSString stringWithFormat:@"readable(%i)", location] buffer:buffer ? *buffer : NULL length:result];
    return result;
}

- (NSUInteger)write:(const void *)buffer range:(NSRange)range {
    NSUInteger result = [super write:buffer range:range];
    [NWIOLogBase logWithBlock:logBlock tag:tag operation:[NSString stringWithFormat:@"write(%i,%i)", range.location, range.length] buffer:buffer length:result];
    return result;
}

- (NSUInteger)writable:(void **)buffer location:(NSUInteger)location {
    NSUInteger result = [super writable:buffer location:location];
    [NWIOLogBase logWithBlock:logBlock tag:tag operation:[NSString stringWithFormat:@"writable(%i), previous", result] buffer:writableBuffer length:writableLength];
    writableBuffer = *buffer;
    writableLength = result;
    return result;
}

- (NSUInteger)inputLength {
    return super.inputLength;
}

- (NSUInteger)outputLength {
    return super.outputLength;
}

#pragma mark - Controls

- (id)control:(id)control {
    id result = [super control:control];
    [NWIOLogBase logWithBlock:logBlock tag:tag control:control result:result];
    return result;
}

@end

