//
//  NWIOMultipart.m
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

#import "NWIOMultipart.h"
#import "NWIOStitch.h"
#import "NWIOData.h"
#import "NWIONSStream.h"

@implementation NWIOMultipartStream {
    NWIOStream *original;
}

@synthesize boundary, parameters, contentFormKey, contentFilename, formDataLength;

- (NSString *)boundaryString {
    NSMutableString *result = [NSMutableString stringWithCapacity:38];
    [result appendString:@"NWIO--"];
    for (NSUInteger i = 0; i < 16; i++) {
        [result appendFormat:@"%02X", rand() & 0xFF];
    }
    return result;
}

- (NSData *)headData {
    // make sure we have some boundary
    if (!boundary) {
        boundary = [self boundaryString];
    }
    NSMutableString *text = [NSMutableString string];
    // add form parameters first
    for(NSString *key in [parameters allKeys]){
        [text appendFormat:@"--%@\r\n", boundary];
        [text appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key];
        [text appendFormat:@"\r\n%@\r\n", [parameters objectForKey:key]];
    }
    // add file content
    [text appendFormat:@"--%@\r\n", boundary];
    [text appendFormat:@"Content-Disposition: form-data", contentFormKey, contentFilename];
    if (contentFormKey) {
        [text appendFormat:@"; name=\"%@\"", contentFormKey];
    }
    if (contentFilename) {
        [text appendFormat:@"; filename=\"%@\"", contentFilename];
    }
    [text appendString:@"\r\n\r\n"];
    return [text dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)footData {
    return [[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)compose {
    // back up current stream
    if (!original) {
        original = stream;
    }
    // collect form data
    NSData *headData = [self headData];
    NSData *footData = [self footData];
    formDataLength = headData.length + footData.length;
    // stitch it
    NWIODataStream *headStream = [[NWIODataStream alloc] initWithInput:headData];
    NWIODataStream *footStream = [[NWIODataStream alloc] initWithInput:footData];
    if (original) {
        stream = [[NWIOStitchStream alloc] initWithStreams:[NSArray arrayWithObjects:headStream, original, footStream, nil]];
    } else {
        stream = [[NWIOStitchStream alloc] initWithStreams:[NSArray arrayWithObjects:headStream, footStream, nil]];
    }
}

- (void)configureRequest:(NSMutableURLRequest *)request streamLength:(NSUInteger)streamLength {
    [request setHTTPBodyStream:[[NWIOInputStream alloc] initWithStream:self]];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%i", formDataLength + streamLength] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
}

@end
