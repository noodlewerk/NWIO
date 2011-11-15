//
//  NWIODigestTest.m
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

#import "NWIODigestTest.h"
#import "NWIO.h"

@implementation NWIODigestTest

- (void)test {
    NSData *data = [@"for the specific language governing permissions" dataUsingEncoding:NSUTF8StringEncoding];
    NWIODigestExtract *extract = [[NWIODigestExtract alloc] init];
    [extract extractFrom:data.bytes length:data.length];
    NWIOHcodeStream *hcodeStream = [[NWIOHcodeStream alloc] initWithInputString:@"cc34c804 e5cabb30 bd736890 49c28345 57a70638" outputString:nil];
    NSData *checkData = [hcodeStream drainFromInputToDataBuffered:YES];
    NSAssert([extract.digest isEqualToData:checkData], @"Should be equal: %@==%@", extract.digest, checkData);
}

@end
