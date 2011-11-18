//
//  NWIOExtract.h
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

#import "NWIOFilter.h"


/**
 * An extract processes data chunks to derive information from it, e.g. to compute a checksum.
 *
 * Subclasses should implement extractFrom:length:. A NULL buffer should be handled well.
 *
 * @warning NB: This is an abstract class. Do not instantiate it directly, but subclass and override abstract methods.
 */
@interface NWIOExtract : NSObject

/**
 * Performs extraction. Abstract.
 * @param buffer -
 * @param length -
 */
- (void)extractFrom:(const unsigned char *)buffer length:(NSUInteger)length;

@end


/**
 * An extract stream is a identity stream that extracts or processes data from the stream, using an NWIOExtract.
 */
@interface NWIOExtractStream : NWIOFilterStream

/**
 * The extract used for processing input data.
 */
@property (nonatomic, strong) NWIOExtract *inputExtract;

/**
 * The extract used for processing output data.
 */
@property (nonatomic, strong) NWIOExtract *outputExtract;

/**
 * A convenience initializer that sets properties and forwards to super.
 * @param stream The stream to chain to.
 * @param inputExtract Assigned to property.
 * @param outputExtract Assigned to property.
 * @return instance
 */
- (id)initWithStream:(NWIOStream *)stream inputExtract:(NWIOExtract *)inputExtract outputExtract:(NWIOExtract *)outputExtract;

@end