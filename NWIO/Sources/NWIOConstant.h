//
//  NWIOConstant.h
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
 * The Constant Stream represents a constant-value source and sink, e.g. /dev/null for 0.
 * IO operations are O(1). Readable and writable initialize their individual buffer on first run.
 */
@interface NWIOConstantStream : NWIOStream
@property (nonatomic, assign) unsigned char constant;
@property (nonatomic, assign) NSUInteger inputLength;
@property (nonatomic, assign) NSUInteger outputLength;
- (id)initWithInputLength:(NSUInteger)input outputLength:(NSUInteger)output;
@end


/**
 * Represents data with a constant value.
 */ 
@interface NWIOConstantAccess : NWIOAccess
@property (nonatomic, assign) unsigned char constant;
@property (nonatomic, assign) NSUInteger inputLength;
@property (nonatomic, assign) NSUInteger outputLength;
- (id)initWithInputLength:(NSUInteger)input outputLength:(NSUInteger)output;
@end
