//
//  NWIOMenuViewController.m
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

#import "NWIOMenuViewController.h"
#import "NWIODemoViewController.h"
#import "NWIOConsoleDemo.h"
#include <objc/runtime.h>

@implementation NWIOMenuViewController {
    NSArray *demos;
}


#pragma mark - Object life cycle

- (NSArray *)demoNames {
    NSMutableArray *result = [NSMutableArray array];
    NSUInteger classCount = objc_getClassList(NULL, 0);
    Class *classes = (Class *)malloc(sizeof(Class) * classCount);
    classCount = objc_getClassList(classes, classCount);
    for (NSUInteger i = 0; i < classCount; i++) {
        NSString *className = NSStringFromClass(classes[i]);
        if ([className hasPrefix:@"NWIO"] && [className hasSuffix:@"Demo"]) {
            NSString *demoName = [className substringWithRange:NSMakeRange(4, className.length - 8)];
            if (demoName.length) {
                [result addObject:demoName];
            }
        }
    }
    free(classes);
    [result sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return result;
}

#pragma mark - View life cycle

- (void)viewDidLoad  {
     demos = [self demoNames];
    [super viewDidLoad];
}


#pragma mark - UITableView subclass

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return demos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [demos objectAtIndex:indexPath.row]];
    NSString *demoName = [demos objectAtIndex:indexPath.row];
    NSString *className = [NSString stringWithFormat:@"NWIO%@Demo", demoName];
    cell.detailTextLabel.text = [NSClassFromString(className) about];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *demoName = [demos objectAtIndex:indexPath.row];
    NSString *className = [NSString stringWithFormat:@"NWIO%@Demo", demoName];
    NWIODemo *demo = [[NSClassFromString(className) alloc] initWithTitle:[NSString stringWithFormat:@"%@ Demo", demoName]];
    if (demo) {
        NWIODemoViewController *logDemoViewController = [[NWIODemoViewController alloc] initWithDemo:demo];
        [self.navigationController pushViewController:logDemoViewController animated:YES];
    }
}

@end
