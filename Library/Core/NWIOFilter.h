//
//  NWIOFilter.h
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
 * A stream that functions as a link in chain of filters. All read and write operations are forwarded to the linked stream and all data is filtered as it passes.
 *
 * @warning NB: This is an abstract class. Do not instantiate it directly, but subclass and override abstract methods.
 */
@interface NWIOFilterStream : NWIOStream {
@protected
    NWIOStream *stream;
}

/**
 * The stream to which the responder is linked.
 */
@property (nonatomic, strong) NWIOStream *stream;

/**
 * Initializes and assigns parameters.
 * @param stream Will be assigned to property.
 */
- (id)initWithStream:(NWIOStream *)stream;

@end


/**
 * An access that functions as a link in chain of accesses. All read and write operations are forwarded to the linked access and all data is filtered as it passes.
 *
 * @warning NB: This is an abstract class. Do not instantiate it directly, but subclass and override abstract methods.
 */
@interface NWIOFilterAccess : NWIOAccess {
@protected
    NWIOAccess *access;
}

/**
 * The access to which the responder is linked.
 */
@property (nonatomic, strong) NWIOAccess *access;

/**
 * Initializes and assigns parameters.
 * @param access Will be assigned to property.
 */
- (id)initWithAccess:(NWIOAccess *)access;

@end