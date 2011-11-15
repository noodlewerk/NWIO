//
//  NWIODemoViewController.m
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

#import "NWIODemoViewController.h"
#import "NWIOConsoleDemo.h"
#import "NWIOConsole.h"


@implementation NWIODemoViewController {
    IBOutlet UITextView *textView;
    IBOutlet UIButton *button;
    NWIODemo *demo;
    BOOL isDone;
}


#pragma mark - Object life cycle

- (id)initWithDemo:(NWIODemo *)_demo {
    self = [super init];
    if (self) {
        demo = _demo;
    }
    return self;
}


#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = demo.title;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [demo goWithDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [demo abort];
}

#pragma mark - Events

- (IBAction)run {
    button.enabled = NO;
    if (isDone) {
        [demo goWithDelegate:self];
        textView.text = @"";
        isDone = NO;
    } else {
        [demo.console input:@"<click>"];
    }
}


#pragma mark - NWIOConsole delegate

- (void)console:(NWIOConsole *)console received:(NSString *)text {
    textView.text = [textView.text stringByAppendingString:text];
    // scroll to bottom
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length, 0)];
}

- (void)consoleWaitingForInput:(NWIOConsole *)console {
    button.enabled = YES;
}

- (void)consoleFinished:(NWIOConsole *)console {
    button.enabled = YES;
    isDone = YES;
}

@end
