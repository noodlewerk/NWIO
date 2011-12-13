//
//  NWIOZcodeTest.m
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

#import "NWIOZcodeTest.h"
#import "NWIOTransformTesting.h"
#import "NWIO.h"


@implementation NWIOZcodeTest

- (void)testPlain:(NSString *)plain coded:(NSString *)coded {
    [NWIOTransformTesting testSingleTransform:[[NWIOZcodeTransform alloc] init] plainString:plain codedString:coded];
    [NWIOTransformTesting testTransform:[[NWIOZcodeTransform alloc] init] plainString:plain codedString:coded];
}

- (void)test {
    [self testPlain:@"" coded:@""];
    
    [self testPlain:@"a" coded:@"a"];
    [self testPlain:@"z" coded:@"z"];
    [self testPlain:@"Z" coded:@"Z5A"];
    
    [self testPlain:@"."   coded:@"Z2E"];
    [self testPlain:@"Z."  coded:@"Z5AZ2E"];
    [self testPlain:@"zZ." coded:@"zZ5AZ2E"];
    
    [self testPlain:@"Machines take me by surprise with great frequency." coded:@"MachinesZ20takeZ20meZ20byZ20surpriseZ20withZ20greatZ20frequencyZ2E"];
}

@end
