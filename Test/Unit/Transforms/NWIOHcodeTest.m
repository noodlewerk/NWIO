//
//  NWIOHcodeTest.m
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

#import "NWIOHcodeTest.h"
#import "NWIOTransformTesting.h"
#import "NWIO.h"


@implementation NWIOHcodeTest

- (void)testPlain:(NSString *)plain coded:(NSString *)coded {
    [NWIOTransformTesting testSingleTransform:[[NWIOHcodeTransform alloc] init] plainString:plain codedString:coded];
    [NWIOTransformTesting testTransform:[[NWIOHcodeTransform alloc] init] plainString:plain codedString:coded];
}

- (void)test {
    [self testPlain:@"" coded:@""];
    
    [self testPlain:@" " coded:@"20"];
    [self testPlain:@"\n" coded:@"0A"];
    
    [self testPlain:@"s"     coded:@"73"];
    [self testPlain:@"ns"    coded:@"6E73"];
    [self testPlain:@"ons"   coded:@"6F6E73"];
    [self testPlain:@"ions"  coded:@"696F6E73"];
    [self testPlain:@"sions" coded:@"73696F6E 73"];
    
    [self testPlain:@"For the specific language governing permissions" coded:@"466F7220 74686520 73706563 69666963 206C616E 67756167 6520676F 7665726E 696E6720 7065726D 69737369 6F6E73"];
}

@end
