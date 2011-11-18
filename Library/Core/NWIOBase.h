//
//  NWIOBase.h
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


/**
 * The default allocation size for buffers. This is often also configurable per class.
 */
extern NSUInteger const NWIODefaultBufferLength;


/**
 * A single abstract base class from which most operations inherit.
 *
 * Base does not provide any concrete functionality. Instead, it functions as a collection of control functions that are common to most operations, for both streaming and accessing.
 *
 * @warning NB: This is an abstract class. Do not instantiate it directly, but subclass and override abstract methods.
 */
@interface NWIOBase : NSObject

/**
 * Retrieves the error, if any, that occurred during the last read operation.
 * @return An NSError if one occurred.
 */
- (NSError *)readError;

/**
 * Retrieves the error, if any, that occurred during the last write operation.
 * @return An NSError if one occurred.
 */
- (NSError *)writeError;

/**
 * Signals there will be no more reads, allowing input resources to be released.
 */
- (void)closeRead;

/**
 * Signals there will be no more writes, allowing output resources to be released.
 */
- (void)closeWrite;

/**
 * Decouples the chain of operations, allowing individual links to be garbage collected. Consequentially, sever should be the last call on a chain.
 * @warning NB: When subclassing, remember to call sever on members before severing from them.
 */
- (void)sever;

/**
 * An open-ended system for sending control instructions along the operation chain. This system remains unused by NWIO itself.
 * @param control An object representing the control operation, e.g. a string constant.
 * @return An object representing the control outcome, e.g. a string contant.
 */
- (id)control:(id)control;

@end
