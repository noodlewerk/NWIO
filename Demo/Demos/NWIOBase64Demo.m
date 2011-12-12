//
//  NWIOBase64Demo.m
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

#import "NWIOBase64Demo.h"
#import "NWIOConsole.h"
#import "NWIO.h"


@implementation NWIOBase64Demo

+ (NSString *)about {
    return @"Some bits to relax.";
}

- (void)task {
    Log(@"In this demo, we stream the string:");
    LogLine();
    Log(NWIODemoText);
    LogLine();
    Log(@"Through a base64 encoder:");
    LogLine();
    NWIOBase64Stream *coder = [[NWIOBase64Stream alloc] initWithInputString:NWIODemoText outputString:nil];
    [coder invert];
    NSString *coded = [coder drainFromInputToStringBuffered:YES];
    Log(coded);
    LogLine();
    Log(@"Which again decodes to: ");
    LogLine();
    NWIOBase64Stream *decoder = [[NWIOBase64Stream alloc] initWithInputString:coded outputString:nil];
    LogDrain(decoder);
}

@end
