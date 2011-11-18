//
//  NWIOConnectionDelegate.h
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

#import "NWIOIdentity.h"


/**
 * Listens to NSURLConnection and streams incoming data.
 *
 * If the response's status code is 200, all data will be streamed though self (identity filter). If the connection is not cancelled, either didFinishBlock or didFailBlock will be invoked.
 */
@interface NWIOConnectionDelegate : NWIOIdentityStream

/**
 * The output stream that will be used in case of a non-200 response
 */
@property (nonatomic, strong) NWIOStream *errorStream;

/**
 * This block will be called when all finishes well.
 */
@property (nonatomic, strong) void(^didFinishBlock)(NSHTTPURLResponse *);

/**
 * The didFailBlock will be called when:
 *
 * - the output stream has an error
 * - the output stream is full
 * - the connection sends [didFailWithError:]
 */
@property (nonatomic, strong) void(^didFailBlock)(NSError *);

@end
