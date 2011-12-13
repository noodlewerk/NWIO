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

- (void)testPlain:(NSString *)plain coded:(NSString *)coded {
    [NWIOTransformTesting testSingleTransform:[[NWIOCaseFlipperTransform alloc] init] plainString:plain codedString:coded];
    [NWIOTransformTesting testTransform:[[NWIOCaseFlipperTransform alloc] init] plainString:plain codedString:coded];
}

- (void)test {
    [self testPlain:@"" coded:@""];
    
    [self testPlain:@"a" coded:@"A"];
    [self testPlain:@" " coded:@" "];
    [self testPlain:@"Z" coded:@"z"];
    
    [self testPlain:@"."    coded:@"."];
    [self testPlain:@"e."   coded:@"E."];
    [self testPlain:@"ge."  coded:@"GE."];
    [self testPlain:@"dge." coded:@"DGE."];
    
    [self testPlain:@"We are not interested in the facT that the brain has the consistency of cold porridge." coded:@"wE ARE NOT INTERESTED IN THE FACt THAT THE BRAIN HAS THE CONSISTENCY OF COLD PORRIDGE."];
}

@end
