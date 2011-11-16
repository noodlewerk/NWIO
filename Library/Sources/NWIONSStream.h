//
//  NWIONSStream.h
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

/**
 * Wraps both NSInputStream and NSOutputSteam.
 */
@interface NWIONSStream : NWIOStream
@property (strong, nonatomic) NSInputStream *input;
@property (strong, nonatomic) NSOutputStream *output;
- (id)initWithInput:(NSInputStream *)input output:(NSOutputStream *)output;
- (id)initWithInput:(NSInputStream *)input;
- (id)initWithOutput:(NSOutputStream *)output;
- (id)initWithInputURL:(NSURL *)inputURL outputURL:(NSURL *)outputURL append:(BOOL)append;
- (id)initWithInputURL:(NSURL *)inputURL;
- (id)initWithOutputURL:(NSURL *)outputURL append:(BOOL)append;
- (id)initWithOutputURL:(NSURL *)outputURL;
@end

/**
 * A NSInputStream.
 */
@interface NWIOInputStream : NSInputStream
@property (strong, nonatomic) NWIOStream *stream;
- (id)initWithStream:(NWIOStream *)stream;
@end

/**
 * A NSOutputStream.
 */
@interface NWIOOutputStream : NSOutputStream
@property (strong, nonatomic) NWIOStream *stream;
- (id)initWithStream:(NWIOStream *)stream;
@end