//
//  NWIOConnectionDelegate.m
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

#import "NWIOConnectionDelegate.h"

@implementation NWIOConnectionDelegate {
    NWIOStream *outputStream;
    NSHTTPURLResponse *response;
}

@synthesize errorStream, didFinishBlock, didFailBlock;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)_response {
    response = _response;
    switch (response.statusCode) {
        case 200: outputStream = self; break;
        default: outputStream = errorStream; break;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    for (NSUInteger offset = 0, written = 0; offset < data.length; offset += written) {
        // write to output
        written = [outputStream write:data.bytes + offset length:data.length - offset];
        if (written == 0) {
            // check for end of stream
            NSError *error = nil;
            if (![outputStream hasWriteSpaceAvailable]) {
                error = [NSError errorWithDomain:NSStringFromClass(self.class) code:0 userInfo:nil];
            } else {
                error = [outputStream writeError];
            }
            if (error) {
                // unable to output more
                [connection cancel];
                didFailBlock(error);
                return;
            }
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self closeWrite];
    didFinishBlock(response);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self closeWrite];
    didFailBlock(error);
}

@end
