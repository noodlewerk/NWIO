//
//  NWIOConsoleDemo.m
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

#import "NWIOConsoleDemo.h"
#import "NWIOConsole.h"


#if TARGET_IPHONE_SIMULATOR
static NSUInteger const NWIOPower = 999999999;
#else
static NSUInteger const NWIOPower = 99999999;
#endif


@implementation NWIOConsoleDemo

+ (NSString *)about {
    return @"Demonstrates the textual console that is used in all demos.";
}

- (void)task {
    Log(@"Welcome to this brief iConsole demo");
    LogWaitOrAbort();
    
    Log(@"This console was made to bring the comfort of a command-line to this human-friendly iDevices. The only command currently available is 'Tap', but could easily expand to a full fledged CLI.");
    LogLine();
    Log(@"Let's do a little demo with a few basic tasks. Happy tapping!");
    LogWaitOrAbort();

    Log(@"The most fundamental task of displaying text is done with the 'Log(..)' command.");
    NSMutableArray *array = [NSMutableArray array];
    // Source: www.did-you-knows.com
    [array addObject:@"11% of people are left handed"];
    [array addObject:@"August has the highest percentage of births"];
    [array addObject:@"unless food is mixed with saliva you can't taste it"];
    [array addObject:@"the average person falls asleep in 7 minutes"];
    [array addObject:@"a bear has 42 teeth"];
    [array addObject:@"an ostrich's eye is bigger than it's brain"];
    [array addObject:@"most lipsticks contain fish scales"];
    [array addObject:@"no two corn flakes look the same"];
    [array addObject:@"lemons contain more sugar than strawberries"];
    [array addObject:@"8% of people have an extra rib"];
    [array addObject:@"85% of plant life is found in the ocean"];
    [array addObject:@"Ralph Lauren's original name was Ralph Lifshitz"];
    [array addObject:@"rabbits like licorice"];
    [array addObject:@"the Hawaiian alphabet has 12 letters"];
    [array addObject:@"'Topolino' is the name for Mickey Mouse Italy"];
    [array addObject:@"a lobsters blood is colorless but when exposed to oxygen it turns blue"];
    [array addObject:@"armadillos have 4 babies at a time and are all the same sex"];
    [array addObject:@"reindeer like bananas"];
    [array addObject:@"the longest recorded flight of a chicken was 13 seconds"];
    [array addObject:@"birds need gravity to swallow"];
    NSString *didYouKnow = [array objectAtIndex:arc4random() % array.count];
    LogLine();
    Log(@"For example: Log(@\"  Did you know %%@?\", didYouKnow) results in:");
    LogLine();
    Log(@"  Did you know %@?", didYouKnow);
    LogWaitOrAbort();

    Log(@"And the console is 80 chars wide:");
    LogLine();
    for(NSUInteger i = 0; i < 80; i++) {
        LogText(@"%c", '0' + (i / 10));
    }
    for(NSUInteger i = 0; i < 80; i++) {
        LogText(@"%c", '0' + (i % 10));
    }
    LogLine();
    LogWaitOrAbort();
    
    Log(@"But we can also do long calculations without blocking the user interface.");
    LogLine();
    LogText(@"For example: 3 ^ %u = ", NWIOPower);
    NSUInteger j = 1;
    for (NSUInteger i = 0; i <= NWIOPower; i++, j *= 3) {
        if (i % ((NWIOPower + 1) / 10) == 1) {
            LogText(@".");
            ReturnOnAbort();
        }
    }
    Log(@" %u (excluding overflow of course)", j);
    LogWaitOrAbort();

    Log(@"And while we're on it:");
    LogLine();
    Log(@"                            )            (        )   ");
    Log(@"                         ( /(  (  (      )\\ )  ( /(   ");
    Log(@"                         )\\()) )\\))(   '(()/(  )\\())  ");
    Log(@"                        ((_)\\ ((_)()\\ )  /(_))((_)\\   ");
    Log(@"                         _((_)_(())\\_)()(_))    ((_)  ");
    Log(@"                        | \\| |\\ \\((_)/ /|_ _|  / _ \\  ");
    Log(@"                        | .` | \\ \\/\\/ /  | |  | (_) | ");
    Log(@"                        |_|\\_|  \\_/\\_/  |___|  \\___/  ");
    LogLine();
    LogLine();
    Log(@"That's about it! If you enjoyed this demo, then please consider running it again.");
}

@end
