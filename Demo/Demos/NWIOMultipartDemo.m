//
//  NWIOMultipartDemo.m
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

#import "NWIOMultipartDemo.h"
#import "NWIOConsole.h"
#import "NWIO.h"

static NSUInteger const NWIOUploadKb = 100;

@implementation NWIOMultipartDemo

+ (NSString *)about {
    return @"Streaming in a HTTP way.";
}

- (void)task {
    Log(@"In this demo, we stream file data wrapped in a HTTP body with content type 'multipart/form-data'");
    LogLine();
    NWIOMultipartStream *multipart = [[NWIOMultipartStream alloc] initWithInputString:@"[filecontent]" outputString:nil];
    multipart.contentFilename = @"file.txt";
    [multipart compose];
    LogDrain(multipart);
    LogWaitOrAbort();

    Log(@"Now for a more natural example with custom boundary and parameters:");
    LogLine();
    NSString *content = @"%PDF-1.3\n1 0 ob\n<< /Length 1 /Filter /FlateDecode>\nstartxref\n10\n%%EOF";
    multipart = [[NWIOMultipartStream alloc] initWithInputString:content outputString:nil];
    multipart.boundary = @"DEMO--BOUNDARY--";
    multipart.contentFilename = @"empty.pdf";
    multipart.contentFormKey = @"file";
    multipart.parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"IE6 the good parts", @"title", nil];
    [multipart compose];
    LogDrain(multipart);
    LogWaitOrAbort();
    
    LogText(@"A now for a practical example: let's upload %iK of random data to myspace.com", NWIOUploadKb);
    NWIORandomStream *random = [[NWIORandomStream alloc] initWithInputLength:NWIOUploadKb * 1000 outputLength:0];
    multipart = [[NWIOMultipartStream alloc] initWithStream:random];
    multipart.contentFilename = @"random";
    [multipart compose];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.myspace.com/"]];
    [multipart configureRequest:request streamLength:random.inputLength];
    NWIOProgressStream *counter = [[NWIOProgressStream alloc] init];
    NWIOConnectionDelegate *delegate = [[NWIOConnectionDelegate alloc] initWithStream:counter];
    __block BOOL working = YES;
    delegate.didFailBlock = ^(NSError *error){
        Log(@"\n");
        Log(@"Something went wrong: %@", error);
        working = NO;
    };
    delegate.didFinishBlock = ^(NSHTTPURLResponse *response){
        Log(@"\n");
        if (response.statusCode == 200) {
            Log(@"That worked well, we received %i bytes response with status code %i.", counter.streamedLength, response.statusCode);
        } else {
            Log(@"Unfortunately we got a response with status code %i.", response.statusCode);
        }
        working = NO;
    };
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:delegate startImmediately:NO];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{[connection start];}];
    for (NSUInteger i = 0; i < 10 && working; i++) {
        LogText(@".");
        [NSThread sleepForTimeInterval:1];
    }
    if (working) {
        [connection cancel];
        Log(@"\n");
        Log(@"That took too long, cancelled request.");
    }
}

@end
