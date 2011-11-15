//
//  NWIODeflateDemo.m
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

#import "NWIODeflateDemo.h"
#import "NWIOConsole.h"
#import "NWIO.h"

static NSUInteger const NWIOConstantLength = 1000;

@implementation NWIODeflateDemo

+ (NSString *)about {
    return @"What is zlib actually?";
}

- (void)task {
    Log(@"In this demo, we deflate the sentence:");
    LogLine();
    Log(NWIODemoText);
    LogLine();
    Log(@"Using zlib for compression and Hcoding for display:");
    LogLine();
    NWIODeflateStream *deflater = [[NWIODeflateStream alloc] initWithInputString:NWIODemoText outputString:nil];
    [deflater invert];
    NWIOProgressStream *counter = [[NWIOProgressStream alloc] initWithStream:deflater];
    NWIOHcodeStream *hcode = [[NWIOHcodeStream alloc] initWithStream:counter];
    [hcode invert];
    LogDrain(hcode);
    LogLine();
    Log(@"Which is only %i bytes, %i%% of the original size.", counter.streamedLength, (counter.streamedLength * 100 + NWIODemoText.length / 2) / NWIODemoText.length);
    LogWaitOrAbort();

    Log(@"What about some constant data. Let's deflate %i ones:", NWIOConstantLength);
    LogLine();
    NWIOConstantStream *constant = [[NWIOConstantStream alloc] initWithInputLength:NWIOConstantLength outputLength:0];
    constant.constant = 1;
    deflater = [[NWIODeflateStream alloc] initWithStream:constant];
    [deflater invert];
    counter = [[NWIOProgressStream alloc] initWithStream:deflater];
    hcode = [[NWIOHcodeStream alloc] initWithStream:counter];
    [hcode invert];
    LogDrain(hcode);
    LogLine();
    Log(@"That's only %i bytes, %i%% of the original size!", counter.streamedLength, (counter.streamedLength * 100 + NWIOConstantLength / 2) / NWIOConstantLength);
}

@end
