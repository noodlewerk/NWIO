//
//  NWIOConvenience.h
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

#import <Foundation/Foundation.h>
#import "NWIOStream.h"
#import "NWIOFilter.h"


@interface NWIOStream (NWIODrainConvenience)
- (void)drainFromInputToOutputBuffered:(BOOL)buffered;
- (void)drainFromSourceBuffered:(BOOL)buffered;
- (NSData *)drainFromInputToDataBuffered:(BOOL)buffered;
- (NSString *)drainFromInputToStringBuffered:(BOOL)buffered;
- (void)drainFromInputToURL:(NSURL *)url buffered:(BOOL)buffered;
- (void)drainFromDataToOutput:(NSData *)data bufferd:(BOOL)buffered;
- (void)drainFromStringToOutput:(NSString *)string bufferd:(BOOL)buffered;
- (void)drainFromURLToOutput:(NSURL *)url bufferd:(BOOL)buffered;
@end


@interface NWIOFilterStream (NWIOFilterStreamConvenience)
- (id)initWithInputData:(NSData *)input outputData:(NSMutableData *)output;
- (id)initWithInputURL:(NSURL *)input outputURL:(NSURL *)output append:(BOOL)append;
- (id)initWithMappedInputURL:(NSURL *)input mappedOutputURL:(NSURL *)output append:(BOOL)append;
- (id)initWithInputString:(NSString *)input outputString:(NSMutableString *)output;
@end


@interface NWIOFilterAccess (NWIOFilterAccessConvenience)
- (id)initWithInputData:(NSData *)input outputData:(NSMutableData *)output;
- (id)initWithInputURL:(NSURL *)input outputURL:(NSURL *)output append:(BOOL)append;
@end
