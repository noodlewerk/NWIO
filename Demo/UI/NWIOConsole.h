//
//  NWIOConsole.h
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

#import <Foundation/Foundation.h>


#define Log(__a,...) {[console writeLine:[NSString stringWithFormat:__a,##__VA_ARGS__]];}
#define LogText(__a,...) {[console write:[NSString stringWithFormat:__a,##__VA_ARGS__]];}
#define LogLine() {[console writeLine:@""];}
#define LogWait() {[console writeLine:@"\nTap to continue..\n\n"];[console readLine];}
#define LogWaitOrAbort() {[console writeLine:@"\nTap to continue..\n\n"];[console readLine];if(console.aborted)return;}
#define LogWaitOrAbortWith(__a) {[console writeLine:@"\nTap to continue..\n\n"];[console readLine];if(console.aborted){{__a;}return;}}
#define LogDrain(__a) {[console drainStream:__a];}
#define LogDrainBuffer(__a,__b,__c) {[console drainStream:__a buffer:__b length:__c];}
#define ReturnOnAbort() {if(console.aborted)return;}
#define ReturnOnAbortWith(__a) {if(console.aborted){{__a;}return;}}

@protocol NWIOConsoleDelegate;
@class NWIOStream;


@protocol NWIOConsoleBack <NSObject>
- (void)input:(NSString *)input;
@end


@interface NWIOConsole : NSObject<NWIOConsoleBack>
@property (weak) id<NWIOConsoleDelegate> delegate;
@property (assign) BOOL aborted;
- (id)initWithDelegate:(id<NWIOConsoleDelegate>)delegate queue:(NSOperationQueue *)delegateQueue;
- (void)write:(NSString *)text;
- (void)writeLine:(NSString *)text;
- (NSString *)readLine;
- (void)drainStream:(NWIOStream *)stream;
- (void)drainStream:(NWIOStream *)stream buffer:(void *)buffer length:(NSUInteger)length;
- (void)finished;
@end


@protocol NWIOConsoleDelegate <NSObject>
- (void)console:(NWIOConsole *)console received:(NSString *)text;
- (void)consoleWaitingForInput:(NWIOConsole *)console;
- (void)consoleFinished:(NWIOConsole *)console;
@end
