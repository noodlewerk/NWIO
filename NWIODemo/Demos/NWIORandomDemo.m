//
//  NWIORandomDemo.m
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

#import "NWIORandomDemo.h"
#import "NWIOConsole.h"
#import "NWIO.h"


#if TARGET_IPHONE_SIMULATOR
static NSUInteger const NWIORandomSizeMB = 100;
#else
static NSUInteger const NWIORandomSizeMB = 10;
#endif


@implementation NWIORandomDemo

+ (NSString *)about {
    return @"What's a framework without some pseudo randomness?";
}

- (void)task {
    Log(@"In this arbitrary demo, we stream %iMB random bytes..", NWIORandomSizeMB);
    LogLine();
    NSUInteger l = NWIORandomSizeMB * 1000 * 1000;
    NWIORandomStream *random = [[NWIORandomStream alloc] initWithInputLength:l outputLength:0];
    NWIOProgressStream *progress = [[NWIOProgressStream alloc] initWithStream:random];
    progress.expectedLength = l;
    progress.intervalLength = l / 10;
    __block BOOL working = YES;
    progress.didStreamLengthBlock = ^(NSUInteger length){if(working)LogText(@".");};
    NWIOHcodeStream *hcode = [[NWIOHcodeStream alloc] initWithStream:progress];
    [hcode invert];
    [hcode drainFromSourceBuffered:YES];
    working = NO;
    Log(@" done. Did you see that progress bar?");
    LogWaitOrAbort();

    Log(@"Now let's waste some more cpu on deflating %i bytes of random data:", NWIORandomSizeMB);
    LogLine();
    random = [[NWIORandomStream alloc] initWithInputLength:NWIORandomSizeMB outputLength:0];
    NWIODeflateStream *deflater = [[NWIODeflateStream alloc] initWithStream:random];
    [deflater invert];
    NWIOProgressStream *counter = [[NWIOProgressStream alloc] initWithStream:deflater];
    hcode = [[NWIOHcodeStream alloc] initWithStream:counter];
    [hcode invert];
    LogDrain(hcode);
    LogLine();
    Log(@"That's %i bytes deflated, but who want to compress noise anyway?", counter.streamedLength);
}

@end
