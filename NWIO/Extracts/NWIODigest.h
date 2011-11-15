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


@interface NWIODigestExtract : NWIOExtract
@property (nonatomic, assign) NWIODigestMethod method;
@property (nonatomic, assign, readonly) NSData *digest;
- (id)initWithStream:(NWIOStream *)stream method:(NWIODigestMethod)method;
@end

/**
 * Convenience stream around NWIODigestExtract
 */
@interface NWIODigestStream : NWIOExtractStream
@property (nonatomic, assign) NWIODigestMethod inputMethod;
@property (nonatomic, assign) NWIODigestMethod outputMethod;
@property (nonatomic, assign, readonly) NSData *inputDigest;
@property (nonatomic, assign, readonly) NSData *outputDigest;
@end