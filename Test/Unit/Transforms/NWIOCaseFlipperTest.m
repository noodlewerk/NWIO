//
//  NWIOCaseFlipperTest.m
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

#import "NWIOCaseFlipperTest.h"
#import "NWIOTransformTesting.h"
#import "NWIO.h"


@implementation NWIOCaseFlipperTest

- (void)test {
    NWIOCaseFlipperTransform *transform = [[NWIOCaseFlipperTransform alloc] init];
    NSData *plain = [@"For the specific language governing permissions" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *coded = [@"fOR THE SPECIFIC LANGUAGE GOVERNING PERMISSIONS" dataUsingEncoding:NSUTF8StringEncoding];
    [NWIOTransformTesting testTransform:transform plain:plain coded:coded];
}

@end
