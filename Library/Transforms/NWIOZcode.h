//
//  NWIOZcode.h
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
 * Takes any binary data and transforms it using a Z-escaped scheme.
 *
 * A distinguishing property of zcoding is, that it results in a text that only contains alpha-numeric characters. This makes a zcoded string compatible with about every file or data format around, while maintaining some human-readability. Of course, this has little use in a production environment, where one always prefer to use a context-custom scheme.
 *
 * This implementation functions mostly as an example on how to implement a custom per-byte transform in an NWIOTransform.
 */
@interface NWIOZcodeTransform : NWIOTransform
@end


/**
 * A transform stream based on the zcode transform.
 */
@interface NWIOZcodeStream : NWIOTransformStream
@end
