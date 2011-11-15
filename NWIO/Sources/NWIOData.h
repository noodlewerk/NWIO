//
//  NWIOData.h
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

#import "NWIOStream.h"
#import "NWIOAccess.h"

/**
 * Streams the content of an NSData.
 */
@interface NWIODataStream : NWIOStream
@property (nonatomic, strong) NSData *input;
@property (nonatomic, strong) NSMutableData *output;
@property (nonatomic, assign) BOOL outputLengthFixed;
@property (nonatomic, assign) NSUInteger outputExpandLength;
- (id)initWithInput:(NSData *)input output:(NSMutableData *)output;
- (id)initWithInput:(NSData *)input;
- (id)initWithOutput:(NSMutableData *)output;

/**
 * Uses cached safe memory mapping. input == nil if not possible.
 * @param url -
 */
- (id)initWithInputURL:(NSURL *)url;
@end

/**
 * Accesses the content of an NSData.
 */
@interface NWIODataAccess : NWIOAccess
@property (nonatomic, strong) NSData *input;
@property (nonatomic, strong) NSMutableData *output;
- (id)initWithInput:(NSData *)input output:(NSMutableData *)output;
- (id)initWithInput:(NSData *)input;
- (id)initWithOutput:(NSMutableData *)output;
/**
 * Uses cached safe memory mapping. input == nil if not possible.
 * @param url -
 */
- (id)initWithInputURL:(NSURL *)url;
@end
