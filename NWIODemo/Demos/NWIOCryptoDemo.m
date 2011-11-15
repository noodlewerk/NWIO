//
//  NWIOCryptoDemo.m
//  NWIO
//
//  Copyright (c) 2011 Noodlewerk
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

#import "NWIOCryptoDemo.h"
#import "NWIOConsole.h"
#import "NWIO.h"


@implementation NWIOCryptoDemo

+ (NSString *)about {
    return @"Do not roll you own crypto, stupid.";
}

- (void)task {
    Log(@"In this demo, we encrypt the sentence:");
    LogLine();
    Log(NWIODemoText);
    LogLine();
    Log(@"using AES128 for encryption and Hcoding for display.");
    LogLine();
    NWIOCryptoStream *encryptor = [[NWIOCryptoStream alloc] initWithInputString:NWIODemoText outputString:nil];
    [encryptor invert];
    NSData *encrypted = [encryptor drainFromInputToDataBuffered:YES];
    NWIOHcodeStream *hcode = [[NWIOHcodeStream alloc] initWithInputData:encrypted outputData:nil];
    [hcode invert];
    LogDrain(hcode);
    LogLine();
    Log(@"Which decrypts to: ");
    LogLine();
    NWIOCryptoStream *decryptor = [[NWIOCryptoStream alloc] initWithInputData:encrypted outputData:nil];
    char buffer[256];
    LogDrainBuffer(decryptor, buffer, sizeof(buffer));
}

@end