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

- (void)testPlain:(NSString *)plain coded:(NSString *)coded {
    [NWIOTransformTesting testTransform:[[NWIOBase64Transform alloc] init] plainString:plain codedString:coded];
}

- (void)test {
    [self testPlain:@"" coded:@""];
    
    [self testPlain:@"s"     coded:@"cw=="];
    [self testPlain:@"su"    coded:@"c3U="];
    [self testPlain:@"sur"   coded:@"c3Vy"];
    [self testPlain:@"sure"  coded:@"c3VyZQ=="];
    [self testPlain:@"sure." coded:@"c3VyZS4="];
    
    [self testPlain:@"any carnal pleas"     coded:@"YW55IGNhcm5hbCBwbGVhcw=="];
    [self testPlain:@"any carnal pleasu"    coded:@"YW55IGNhcm5hbCBwbGVhc3U="];
    [self testPlain:@"any carnal pleasur"   coded:@"YW55IGNhcm5hbCBwbGVhc3Vy"];
    [self testPlain:@"any carnal pleasure"  coded:@"YW55IGNhcm5hbCBwbGVhc3VyZQ=="];
    [self testPlain:@"any carnal pleasure." coded:@"YW55IGNhcm5hbCBwbGVhc3VyZS4="];
    
    [self testPlain:@"Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure." coded:@"TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4="];
}

@end
