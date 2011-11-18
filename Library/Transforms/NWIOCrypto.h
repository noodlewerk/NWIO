//
//  NWIOCrypto.h
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

#import "NWIOTransform.h"


/**
 * An experimental implementation of CBC AES 128-bit using Common Crypto.
 *
 * @warning This implementation functions mostly as an example crypto implementation. It should by no measures be considered safe for use in production environments.
 */
@interface NWIOCryptoTransform : NWIOTransform

/**
 * The 16-byte key data used for AES.
 */
@property (nonatomic, strong) NSData *key;

/**
 * The 16-byte iv data used for CBC.
 */
@property (nonatomic, strong) NSData *iv;

@end


/**
 * A filter stream based on the crypto transform.
 * @see NWIOCryptoTransform
 */
@interface NWIOCryptoStream : NWIOTransformStream

/**
 * Forwards to underlying crypto transform.
 * @see [NWIOCryptoTransform key]
 */
@property (nonatomic, strong) NSData *key;

/**
 * Forwards to underlying crypto transform.
 * @see [NWIOCryptoTransform iv]
 */
@property (nonatomic, strong) NSData *iv;

@end


/**
 * A filter access based on the crypto transform.
 * @see NWIOCryptoTransform
 */
@interface NWIOCryptoAccess : NWIOFilterAccess

/**
 * The length of the plain (deciphered) input text.
 * NB: needs to be assigend prior to sending read or write messages.
 */
@property (nonatomic, assign) NSUInteger inputLength;

/**
 * The length of the plain (deciphered) output text.
 * NB: needs to be assigend prior to sending read or write messages.
 */
@property (nonatomic, assign) NSUInteger outputLength;

/**
 * Forwards to underlying crypto transform.
 * @see [NWIOCryptoTransform key]
 */
@property (nonatomic, strong) NSData *key;

/**
 * Forwards to underlying crypto transform.
 * @see [NWIOCryptoTransform iv]
 */
@property (nonatomic, strong) NSData *iv;

@end