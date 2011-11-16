//
//  NWIOConsole.m
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

#import "NWIOConsole.h"
#import "NWIOStream.h"

#define NWIO_DEFAULT_DRAIN_LENGTH 32

@implementation NWIOConsole {
    NSString *line;
    NSOperationQueue *delegateQueue;
}

@synthesize delegate, aborted;


#pragma mark - Object life cycle

- (id)initWithDelegate:(id<NWIOConsoleDelegate>)_delegate queue:(NSOperationQueue *)_delegateQueue {
    self = [super init];
    if (self) {
        line = @"";
        delegate = _delegate;
        delegateQueue = _delegateQueue;
    }
    return self;
}


#pragma mark - IO

- (void)input:(NSString *)input {
    @synchronized (self) {
        line = input;
    }
}

- (NSString *)readLine {
    @synchronized (self) {
         line = nil;
    }
    __weak NWIOConsole *s = self;
    [delegateQueue addOperationWithBlock:^{[s.delegate consoleWaitingForInput:s];}];
    for (;;) {
        NSString *result = nil;
        @synchronized (self) {
            if (line) {
                result = line;
                line = nil;
            }
        }
        if (result) {
            return result;
        }
        if (aborted) {
            return nil;
        }
        [NSThread sleepForTimeInterval:.1];
    }
}

- (void)writeLine:(NSString *)text {
    __weak NWIOConsole *s = self;
    [delegateQueue addOperationWithBlock:^{[s.delegate console:s received:[NSString stringWithFormat:@"%@\n", text]];}];
}

- (void)write:(NSString *)text {
    __weak NWIOConsole *s = self;
    [delegateQueue addOperationWithBlock:^{[s.delegate console:s received:text];}];
}

- (void)drainStream:(NWIOStream *)stream {
    char buffer[NWIO_DEFAULT_DRAIN_LENGTH];
    [self drainStream:stream buffer:buffer length:sizeof(buffer)];
}

- (void)drainStream:(NWIOStream *)stream buffer:(void *)buffer length:(NSUInteger)length {
    for (;;) {
        NSUInteger read = [stream read:buffer length:length];
        if (read) {
            [self write:[NSString stringWithFormat:@"%.*s", read, buffer]];
        } else if ([stream hasReadEndedOrFailed:nil]) {
            break;
        }
    }
    [self writeLine:@""];
}

- (void)finished {
    __weak NWIOConsole *s = self;
    [delegateQueue addOperationWithBlock:^{[s.delegate consoleFinished:s];}];
}

@end
