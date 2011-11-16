//
//  NWIOTransform.h
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

#import "NWIOFilter.h"


/**
 * A transform provides a coding operation, allowing the stream to be decoded on read and encoded on write. This class provides the glue between NWIO streams and the actual transform that sequentially operates on buffers.
 * Although not a necessity, it is generally assumed that encoding followd by decoding equals the identity operation.
 */
@interface NWIOTransform: NSObject
// Subclass and override these:
- (BOOL)transformBackwardFromBuffer:(const unsigned char *)fromBuffer fromLength:(NSUInteger)fromLength fromInc:(NSUInteger *)fromInc toBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error;
- (BOOL)transformForwardFromBuffer:(const unsigned char *)fromBuffer fromLength:(NSUInteger)fromLength fromInc:(NSUInteger *)fromInc toBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error;
- (BOOL)flushBackwardToBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error;
- (BOOL)flushForwardToBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error;
- (void)resetBackward;
- (void)resetForward;
@end


/**
 * Pulls all passing data though a given transform.
 */
@interface NWIOTransformStream : NWIOFilterStream

// Allows the operation to be inverted; encoding on read and decoding on write.
// TODO: make sure setting this value during streaming doesnt cause trouble, e.g. gets ignored
@property (nonatomic, strong) NWIOTransform *transform;
@property (nonatomic, assign) BOOL inverted;

- (id)initWithStream:(NWIOStream *)stream transform:(NWIOTransform *)transform inverted:(BOOL)inverted;
- (id)initWithStream:(NWIOStream *)stream transform:(NWIOTransform *)transform;
- (id)initWithTransform:(NWIOTransform *)transform;
- (void)invert;

@end

