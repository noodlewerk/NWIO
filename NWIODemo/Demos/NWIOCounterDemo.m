//
//  NWIOCounterDemo.m
//  NWIO
//
//  Copyright (c) 2011 Noodlewerk
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

#import "NWIOCounterDemo.h"
#import "NWIOConsole.h"
#import "NWIO.h"


#if TARGET_IPHONE_SIMULATOR
static NSUInteger const NWIORandomSizeMB = 100;
#else
static NSUInteger const NWIORandomSizeMB = 10;
#endif


@implementation NWIOCounterDemo

+ (NSString *)about {
    return @"Compares performance on a basic character-counting task.";
}

- (NSUInteger)streamingZeroCountOnFile:(NSURL *)file {
    NWIOCounterStream *counter = [[NWIOCounterStream alloc] initWithInputURL:file outputURL:nil append:NO];
    [counter drainFromSourceBuffered:YES];
    return [counter inputFrequency:0];
}

- (NSUInteger)dedicatedZeroCountOnFile:(NSURL *)file {
    NSUInteger result = 0;
    NSInputStream *stream = [NSInputStream inputStreamWithURL:file];
    [stream open];
    NSUInteger bufferLength = NWIODefaultBufferLength;
    uint8_t *buffer = malloc(bufferLength);
    while ([stream hasBytesAvailable]) {
        NSUInteger read = [stream read:buffer maxLength:bufferLength];
        if (read > 0) {
            for (uint8_t *i = buffer, *end = i + read; i < end; i++) {
                if (*i == 0) {
                    result++;
                }
            }
        }
    }
    free(buffer);
    [stream close];
    return result;
}

- (void)task {
    LogLine();
    Log(@"In this demo we run a little performance test. Let's count the number of zeros in a %iMB file.", NWIORandomSizeMB);
    LogLine();
    LogLine();
    LogText(@"First we write random bytes to a temporary file..");

    NSString *documentFolderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *fileURL = [[NSURL fileURLWithPath:documentFolderPath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%i.txt", (NSUInteger)([[NSDate date] timeIntervalSince1970] * 1000)]];

    NWIORandomStream *random = [[NWIORandomStream alloc] initWithInputLength:NWIORandomSizeMB * 1000 * 1000 outputLength:0];
    [random drainFromInputToURL:fileURL buffered:YES];
    Log(@"..done");
    LogWaitOrAbort();
    
    void(^cleanup)() = ^{[[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];};
    
    for(;;){
        Log(@"First we count them using a NWIOCounter..");
        NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
        NSUInteger count = [self streamingZeroCountOnFile:fileURL];
        NSTimeInterval end = [[NSDate date] timeIntervalSince1970];
        NSUInteger diff = (NSUInteger)((end - start) * 1000);
        Log(@".. which takes about %i ms. We counted %i zeros", diff, count);
        LogLine();

        Log(@"Now we count them using a custom implementation..");
        NSTimeInterval start2 = [[NSDate date] timeIntervalSince1970];
        NSUInteger count2 = [self dedicatedZeroCountOnFile:fileURL];
        NSTimeInterval end2 = [[NSDate date] timeIntervalSince1970];
        NSUInteger diff2 = (NSUInteger)((end2 - start2) * 1000);
        Log(@".. which takes about %i ms. We counted %i zeros", diff2, count2);
        LogLine();
        double d = ((double)diff - diff2) * 100 / diff;
        if (d > 5) {
            Log(@"A %i%% difference, quite something, but these tests aren't very reliable.", (NSInteger)d);
        } else if (d > 0) {
            Log(@"That's only %.2f%% difference, NWIO can really compete!", d);
            cleanup();
            return;
        } else {
            Log(@"Wow, it's even faster! Maybe this performance test is not that reliable...");
        }
        LogWaitOrAbortWith(cleanup());
        Log(@"Let's run it again..");
        LogLine();
    }
}

@end
