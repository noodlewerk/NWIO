//
//  NWIOZcodeDemo.m
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

#import "NWIOZcodeDemo.h"
#import "NWIOConsole.h"
#import "NWIO.h"


@implementation NWIOZcodeDemo

+ (NSString *)about {
    return @"Simple but universal way to move binary data though a alpha-numeric world.";
}

- (void)task {
    Log(@"In this demo, we stream the string:");
    LogLine();
    Log(NWIODemoText);
    LogLine();
    Log(@"Through an alpha-numeric-only encoder that uses 'Z' as escape:");
    LogLine();
    NWIOZcodeStream *coder = [[NWIOZcodeStream alloc] initWithInputString:NWIODemoText outputString:nil];
    [coder invert];
    NSString *coded = [coder drainFromInputToStringBuffered:YES];
    Log(coded);
    LogLine();
    Log(@"Which again decodes to: ");
    LogLine();
    NWIOZcodeStream *decoder = [[NWIOZcodeStream alloc] initWithInputString:coded outputString:nil];
    LogDrain(decoder);
    LogWaitOrAbort();
    
    Log(@"The nice thing about Zcoding is, that it results in a text that only contains alpha-numeric characters. This makes a Zcoded string compatible with about every file or data format around, while maintaining some human-readability. Of course, this has little use in a production environment, where one always prefer to use a context-custom scheme.");
}

@end
