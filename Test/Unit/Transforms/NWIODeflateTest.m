//
//  NWIODeflateTest.m
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

#import "NWIODeflateTest.h"
#import "NWIOTransformTesting.h"
#import "NWIO.h"


@implementation NWIODeflateTest

- (void)test {
    NWIODeflateTransform *transform = [[NWIODeflateTransform alloc] init];
    NSData *plain = [@"For the specific language governing permissions" dataUsingEncoding:NSUTF8StringEncoding];
    NWIOHcodeStream *hcodeStream = [[NWIOHcodeStream alloc] initWithInputString:@"789C05C1 810DC020 0C03B057 72CDFE40 2894485B 8B5AD8FD D84F24F6 246AB16B A8E36D6E A71961F1 335D6E58 CC4F550A AF0BA496 121E" outputString:nil];
    NSData *coded = [hcodeStream drainFromInputToDataBuffered:NO];
    [NWIOTransformTesting testTransform:transform plain:plain coded:coded];
}

@end
