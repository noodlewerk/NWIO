//
//  NWIOCounter.m
//  NWIO
//
//  Copyright (c) 2011 Noodlewerk
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

#import "NWIOCounter.h"

@implementation NWIOCounterExtract {
    NSUInteger frequencies[256];
}

- (void)extractFrom:(const unsigned char *)buffer length:(NSUInteger)length {
    for (const unsigned char *end = buffer + length; buffer < end; buffer++) {
        frequencies[*buffer]++;
    }
}

- (NSUInteger)frequencyOfByte:(unsigned char)byte {
    return frequencies[byte];
}

@end


@implementation NWIOCounterStream

- (id)initWithStream:(NWIOStream *)_stream {
    return [super initWithStream:_stream inputExtract:[[NWIOCounterExtract alloc] init] outputExtract:[[NWIOCounterExtract alloc] init]];
}

- (NSUInteger)inputFrequency:(unsigned char)byte {
    return [(NWIOCounterExtract *)self.inputExtract frequencyOfByte:byte];
}

- (NSUInteger)outputFrequency:(unsigned char)byte {
    return [(NWIOCounterExtract *)self.outputExtract frequencyOfByte:byte];
}


@end