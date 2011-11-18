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
 * A transform provides a coding operation, allowing the stream to be decoded on read and encoded on write. Although not a necessity, it is generally assumed that froward transforming followed by reverse transforming equals the identity transform.
 *
 * Subclasses should implement all methods. A NULL buffer should be handled well.
 *
 * @warning NB: This is an abstract class. Do not instantiate it directly, but subclass and override abstract methods.
 */
@interface NWIOTransform: NSObject

/**
 * Reverse-transforms data in 'from' buffer and outputs in 'to' buffer.
 * @param fromBuffer Transformation input bytes.
 * @param fromLength Transformation input length.
 * @param fromInc Assigned the number of input bytes processed.
 * @param toBuffer Transformation output bytes.
 * @param toLength Transformation output length.
 * @param toInc Assigned the number of output bytes written.
 * @param error Assigned if an error occurs.
 * @return YES if no error occurred.
 */
- (BOOL)transformBackwardFromBuffer:(const unsigned char *)fromBuffer fromLength:(NSUInteger)fromLength fromInc:(NSUInteger *)fromInc toBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error;

/**
 * Forward-transforms data in 'from' buffer and outputs in 'to' buffer.
 * @param fromBuffer Transformation input bytes.
 * @param fromLength Transformation input length.
 * @param fromInc Assigned the number of input bytes processed.
 * @param toBuffer Transformation output bytes.
 * @param toLength Transformation output length.
 * @param toInc Assigned the number of output bytes written.
 * @param error Assigned if an error occurs.
 * @return YES if no error occurred.
 */
- (BOOL)transformForwardFromBuffer:(const unsigned char *)fromBuffer fromLength:(NSUInteger)fromLength fromInc:(NSUInteger *)fromInc toBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error;

/**
 * Flushes remaining reverse-transformation data in 'to' buffer.
 * @param toBuffer Transformation output bytes.
 * @param toLength Transformation output length.
 * @param toInc Assigned the number of output bytes written.
 * @param error Assigned if an error occurs.
 * @return YES if no error occurred.
 */
- (BOOL)flushBackwardToBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error;

/**
 * Flushes remaining forward-transformation data in 'to' buffer.
 * @param toBuffer Transformation output bytes.
 * @param toLength Transformation output length.
 * @param toInc Assigned the number of output bytes written.
 * @param error Assigned if an error occurs.
 * @return YES if no error occurred.
 */
- (BOOL)flushForwardToBuffer:(unsigned char *)toBuffer toLength:(NSUInteger)toLength toInc:(NSUInteger *)toInc error:(NSError **)error;

/**
 * Resets the internal state of the reverse transform.
 * @see [NWIOStream rewindRead]
 */
- (void)resetBackward;

/**
 * Resets the internal state of the forward transform.
 * @see [NWIOStream rewindWrite]
 */
- (void)resetForward;

@end


/**
 * A transform stream is a filter stream that pulls all passing data though a given transform.
 */
@interface NWIOTransformStream : NWIOFilterStream

/**
 * Allows the operation to be inverted; encoding on read and decoding on write.
 */
@property (nonatomic, strong) NWIOTransform *transform;

/**
 * If YES, the transform will be applied inversely.
 */
@property (nonatomic, assign) BOOL inverted;

/**
 * Assigns parameters and forward to super.
 * @param stream -
 * @param transform -
 * @param inverted -
 * @return -
 */
- (id)initWithStream:(NWIOStream *)stream transform:(NWIOTransform *)transform inverted:(BOOL)inverted;

/**
 * @see initWithStream:transform:inverted:
 * @param stream -
 * @param transform -
 */
- (id)initWithStream:(NWIOStream *)stream transform:(NWIOTransform *)transform;

/**
 * @see initWithStream:transform:inverted:
 * @param transform -
 * @return -
 */
- (id)initWithTransform:(NWIOTransform *)transform;

/**
 * Sets the inverted property to YES.
 * @see inverted
 */
- (void)invert;

@end

