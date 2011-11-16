//
//  NWIOHcodeDemo.m
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

#import "NWIOHcodeDemo.h"
#import "NWIOConsole.h"
#import "NWIO.h"


@implementation NWIOHcodeDemo

+ (NSString *)about {
    return @"Makes binary data 'human readable'.";
}

- (void)task {
    Log(@"In this demo, we stream the string:");
    LogLine();
    Log(NWIODemoText);
    LogLine();
    Log(@"Through an hex coder:");
    LogLine();
    NWIOHcodeStream *coder = [[NWIOHcodeStream alloc] initWithInputString:NWIODemoText outputString:nil];
    [coder invert];
    NSString *coded = [coder drainFromInputToStringBuffered:YES];
    Log(coded);
    LogWaitOrAbort();

    Log(@"Which again decodes to: ");
    LogLine();
    NWIOHcodeStream *decoder = [[NWIOHcodeStream alloc] initWithInputString:coded outputString:nil];
    LogDrain(decoder);
    LogWaitOrAbort();
    
    Log(@"Also consider checking out the Log demo. This will show you the log stream, which is much more comfortable while debugging:");
    LogLine();
    NWIOLogStream *log = [[NWIOLogStream alloc] initWithInputString:NWIODemoText outputString:nil];
    log.logBlock = ^(NSString *line){Log(line);};
    [log drainFromSourceBuffered:NO];
}

@end
