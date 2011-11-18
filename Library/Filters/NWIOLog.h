//
//  NWIOLog.h
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
 * Logs all operations that pass thought this filter.
 *
 * By default logs with NSLog(..).
 * NB: Calls to logBlock take place during the IO operation.
 */
@interface NWIOLogStream : NWIOIdentityStream

/**
 * A small test that will be prefixed to every log entry.
 */
@property (nonatomic, strong) NSString *tag;

/**
 * Will be invoked for every log entry.
 */
@property (nonatomic, strong) void(^logBlock)(NSString *);

@end


/**
 * Logs all operations that pass thought this filter.
 *
 * By default logs with NSLog(..).
 * NB: Calls to logBlock take place during the IO operation.
 */
@interface NWIOLogAccess : NWIOIdentityAccess

/**
 * A small test that will be prefixed to every log entry.
 */
@property (nonatomic, strong) NSString *tag;

/**
 * Will be invoked for every log entry.
 */
@property (nonatomic, strong) void(^logBlock)(NSString *);

@end
