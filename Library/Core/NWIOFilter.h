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
 * A stream that functions as a link in chain of filters, each observing or manipulating the data that passing through.
 *
 * @warning: This is an abstract class, do not instantiate it directly.
 */
@interface NWIOFilterStream : NWIOStream {
@protected
    NWIOStream *stream;
}
@property (nonatomic, strong) NWIOStream *stream;
- (id)initWithStream:(NWIOStream *)stream;
@end


@interface NWIOFilterAccess : NWIOAccess {
@protected
    NWIOAccess *access;
}
@property (nonatomic, strong) NWIOAccess *access;
- (id)initWithAccess:(NWIOAccess *)access;
@end