//
//  NWIODrain.h
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


@class NWIOStream;

/**
 * Full drains a source stream to a sink stream using repeated read/writes.
 */
@interface NWIODrain : NSObject
@property (nonatomic, strong) NWIOStream *source;
@property (nonatomic, strong) NWIOStream *sink;
@property (nonatomic, assign) BOOL buffered;
@property (nonatomic, assign) NSUInteger bufferLength;

- (id)initWithSource:(NWIOStream *)source sink:(NWIOStream *)sink;
- (id)initWithSource:(NWIOStream *)source;
- (id)initWithSink:(NWIOStream *)sink;
- (id)initWithSourceAndSink:(NWIOStream *)sourceAndSink;
- (void)setSourceAndSink:(NWIOStream *)sourceAndSink;

- (NSUInteger)run;
- (void)rewind;

@end

