//
//  NWIODemo.h
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

extern NSString * const NWIODemoText;

@class NWIOConsole, NWIOConsole;
@protocol NWIOConsoleDelegate;


@interface NWIODemo : NSObject {
@protected
    NWIOConsole *console;
}
@property (nonatomic, strong) NWIOConsole *console;
@property (nonatomic, strong) NSString *title;
- (id)initWithTitle:(NSString *)title;
- (id)goWithDelegate:(id<NWIOConsoleDelegate>)delegate;
- (void)task;
- (void)abort;
+ (NSString *)about;
@end
