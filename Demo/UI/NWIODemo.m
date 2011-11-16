//
//  NWIODemo.m
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

#import "NWIODemo.h"
#import "NWIOConsole.h"

NSString * const NWIODemoText = @"This blindness of logicians is indeed surprising. But I think the explanation is not hard to find.\nIt lies in a widespread lack, at that time, of the required epistemological attitude toward metamathematics and toward non-finitary reasoning.";


@implementation NWIODemo

@synthesize console, title;

- (id)initWithTitle:(NSString *)_title {
    self = [super init];
    if (self) {
        title = _title;
    }
    return self;
}

- (void)task {}

- (id)goWithDelegate:(id<NWIOConsoleDelegate>)_delegate {
    console = [[NWIOConsole alloc] initWithDelegate:_delegate queue:[NSOperationQueue currentQueue]];
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        [self task];
        [console writeLine:@"\n\nTap to restart..\n"];
        [console finished];
    }];
    return self;
}

- (void)abort {
    console.aborted = YES;
}

+ (NSString *)about {
    return @"Some demo, go for it!";
}

@end
