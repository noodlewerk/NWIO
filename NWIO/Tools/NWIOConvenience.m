//
//  NWIOConvenience.m
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

#import "NWIOConvenience.h"
#import "NWIOData.h"
#import "NWIOString.h"
#import "NWIODrain.h"
#import "NWIONSStream.h"


@implementation NWIOStream (NWIODrainConvenience)


#pragma mark - Generic draining

- (void)drainFromInputToOutputBuffered:(BOOL)buffered {
    NWIODrain *drain = [[NWIODrain alloc] initWithSourceAndSink:self];
    drain.buffered = buffered;
    [drain run];
}

- (void)drainFromSourceBuffered:(BOOL)buffered {
    NWIODrain *drain = [[NWIODrain alloc] initWithSource:self];
    drain.buffered = buffered;
    [drain run];
}


#pragma mark - Drain to

- (NSData *)drainFromInputToDataBuffered:(BOOL)buffered {
    NSMutableData *result = [NSMutableData data];
    NWIODataStream *stream = [[NWIODataStream alloc] initWithOutput:result];
    NWIODrain *drain = [[NWIODrain alloc] initWithSource:self sink:stream];
    drain.buffered = buffered;
    [drain run];
    return result;
}

- (NSString *)drainFromInputToStringBuffered:(BOOL)buffered {
    NSMutableString *result = [NSMutableString string];
    NWIOStringStream *stream = [[NWIOStringStream alloc] initWithOutput:result];
    NWIODrain *drain = [[NWIODrain alloc] initWithSource:self sink:stream];
    drain.buffered = buffered;
    [drain run];
    return result;
}

- (void)drainFromInputToURL:(NSURL *)url buffered:(BOOL)buffered {
    NWIONSStream *stream = [[NWIONSStream alloc] initWithOutputURL:url];
    NWIODrain *drain = [[NWIODrain alloc] initWithSource:self sink:stream];
    drain.buffered = buffered;
    [drain run];
}


#pragma mark - Drain from

- (void)drainFromDataToOutput:(NSData *)data bufferd:(BOOL)buffered {
    NWIODataStream *stream = [[NWIODataStream alloc] initWithInput:data];
    NWIODrain *drain = [[NWIODrain alloc] initWithSource:stream sink:self];
    drain.buffered = buffered;
    [drain run];
}

- (void)drainFromStringToOutput:(NSString *)string bufferd:(BOOL)buffered {
    NWIOStringStream *stream = [[NWIOStringStream alloc] initWithInput:string];
    NWIODrain *drain = [[NWIODrain alloc] initWithSource:stream sink:self];
    drain.buffered = buffered;
    [drain run];
}

- (void)drainFromURLToOutput:(NSURL *)url bufferd:(BOOL)buffered {
    NWIONSStream *stream = [[NWIONSStream alloc] initWithInputURL:url];
    NWIODrain *drain = [[NWIODrain alloc] initWithSource:stream sink:self];
    drain.buffered = buffered;
    [drain run];
}

@end



@implementation NWIOFilterStream (NWIOFilterStreamConvenience)

- (id)initWithInputData:(NSData *)input outputData:(NSMutableData *)output {
    return [self initWithStream:[[NWIODataStream alloc] initWithInput:input output:output]];
}

- (id)initWithInputURL:(NSURL *)input outputURL:(NSURL *)output append:(BOOL)append {
    return [self initWithStream:[[NWIONSStream alloc] initWithInputURL:input outputURL:output append:append]];
}

- (id)initWithMappedInputURL:(NSURL *)input mappedOutputURL:(NSURL *)output append:(BOOL)append {
    NSAssert(!output, @"mapped output not yet supported");
    return [self initWithStream:[[NWIODataStream alloc] initWithInputURL:input]];
}

- (id)initWithInputString:(NSString *)input outputString:(NSMutableString *)output {
    return [self initWithStream:[[NWIOStringStream alloc] initWithInput:input output:output]];
}

@end



@implementation NWIOFilterAccess (NWIOFilterAccessConvenience)

- (id)initWithInputData:(NSData *)input outputData:(NSMutableData *)output {
    return [self initWithAccess:[[NWIODataAccess alloc] initWithInput:input output:output]];
}

- (id)initWithInputURL:(NSURL *)input outputURL:(NSURL *)output append:(BOOL)append {
    NSAssert(!output, @"output not yet supported");
    return [self initWithAccess:[[NWIODataAccess alloc] initWithInputURL:input]];
}

@end

