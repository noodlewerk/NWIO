//
//  NWIOBase64Test.m
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

#import "NWIOBase64Test.h"
#import "NWIOTransformTesting.h"
#import "NWIO.h"


@implementation NWIOBase64Test

- (void)check:(NSString *)plain coded:(NSString *)coded {
    // backward
    NWIOBase64Stream *backward = [[NWIOBase64Stream alloc] initWithInputString:coded outputString:nil];
    NSString *toPlain = [backward drainFromInputToStringBuffered:NO];
    NSAssert([plain isEqualToString:toPlain], @"\n%@*\n%@*", plain, toPlain);
    // forward
    NWIOBase64Stream *forward = [[NWIOBase64Stream alloc] initWithInputString:plain outputString:nil];
    [forward invert];
    NSString *toCoded = [forward drainFromInputToStringBuffered:NO];
    NSAssert([coded isEqualToString:toCoded], @"\n%@*\n%@*", coded, toCoded);
}

- (void)test {
    [self check:@"s"     coded:@"cw=="];
    [self check:@"su"    coded:@"c3U="];
    [self check:@"sur"   coded:@"c3Vy"];
    [self check:@"sure"  coded:@"c3VyZQ=="];
    [self check:@"sure." coded:@"c3VyZS4="];
    [self check:@"any carnal pleas"     coded:@"YW55IGNhcm5hbCBwbGVhcw=="];
    [self check:@"any carnal pleasu"    coded:@"YW55IGNhcm5hbCBwbGVhc3U="];
    [self check:@"any carnal pleasur"   coded:@"YW55IGNhcm5hbCBwbGVhc3Vy"];
    [self check:@"any carnal pleasure"  coded:@"YW55IGNhcm5hbCBwbGVhc3VyZQ=="];
    [self check:@"any carnal pleasure." coded:@"YW55IGNhcm5hbCBwbGVhc3VyZS4="];
    [self check:@"Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure." coded:@"TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4="];
}

@end
