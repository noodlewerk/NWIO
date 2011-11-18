//
//  NWIODigest.h
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

#import "NWIOExtract.h"


typedef enum {
    NWIODigestMethodMD2 = 3,
    NWIODigestMethodMD4 = 4,
    NWIODigestMethodMD5 = 5,
    NWIODigestMethodSHA1 = 0,
    NWIODigestMethodSHA256 = 1,
    NWIODigestMethodSHA512 = 2,
} NWIODigestMethod;


/**
 * Hashes passing data using NWIODigestMethod.
 * @see NWIODigestStream
 * @see http://en.wikipedia.org/wiki/Message_digest
 */
@interface NWIODigestExtract : NWIOExtract

/**
 * The cryptographic hash function used.
 */
@property (nonatomic, assign) NWIODigestMethod method;

/**
 * The hash value data of all data hashed so far. 
 */
@property (nonatomic, assign, readonly) NSData *digest;

@end


/**
 * Convenience stream around NWIODigestExtract.
 * @see NWIODigestExtract
 */
@interface NWIODigestStream : NWIOExtractStream

/**
 * Forwards to underlying input extract.
 * @see [NWIODigestExtract method]
 */
@property (nonatomic, assign) NWIODigestMethod inputMethod;

/**
 * Forwards to underlying output extract.
 * @see [NWIODigestExtract method]
 */
@property (nonatomic, assign) NWIODigestMethod outputMethod;

/**
 * Forwards to underlying input extract.
 * @see [NWIODigestExtract digest]
 */
@property (nonatomic, assign, readonly) NSData *inputDigest;

/**
 * Forwards to underlying output extract.
 * @see [NWIODigestExtract digest]
 */
@property (nonatomic, assign, readonly) NSData *outputDigest;

@end