//
//  NWIOCounter.h
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

#import "NWIOExtract.h"


/**
 * Counts the occurrence of byte values (0 to 255).
 * @see NWIOCounterStream
 */
@interface NWIOCounterExtract : NWIOExtract

/**
 * Provides the frequency of a given byte value.
 * @param byte A byte value (0 to 255).
 * @return The number of occurrences
 */
- (NSUInteger)frequencyOfByte:(unsigned char)byte;

@end


/**
 * Convenience stream around NWIOCounterExtract.
 * @see NWIOCounterExtract
 */
@interface NWIOCounterStream : NWIOExtractStream

/**
 * Forwards to underlying input extract.
 * @param byte A byte value (0 to 255).
 * @see [NWIOCounterExtract frequencyOfByte:]
 */
- (NSUInteger)inputFrequency:(unsigned char)byte;

/**
 * Forwards to underlying output extract.
 * @param byte A byte value (0 to 255).
 * @see [NWIOCounterExtract frequencyOfByte:]
 */
- (NSUInteger)outputFrequency:(unsigned char)byte;

@end