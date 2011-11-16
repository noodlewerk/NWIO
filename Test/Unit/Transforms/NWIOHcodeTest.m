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

- (void)test {
    NWIOHcodeTransform *transform = [[NWIOHcodeTransform alloc] init];
    NSData *plain = [@"For the specific language governing permissions" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *coded = [@"466F7220 74686520 73706563 69666963 206C616E 67756167 6520676F 7665726E 696E6720 7065726D 69737369 6F6E73" dataUsingEncoding:NSUTF8StringEncoding];
    [NWIOTransformTesting testTransform:transform plain:plain coded:coded];
}

@end
