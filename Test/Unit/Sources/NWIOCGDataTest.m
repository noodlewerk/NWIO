//
//  NWIOCGDataTest.m
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

#import "NWIOCGDataTest.h"
#import "NWIO.h"

@implementation NWIOCGDataTest

- (void)checkProvider:(CGDataProviderRef)provider {
    CGPDFDocumentRef document = CGPDFDocumentCreateWithProvider(provider);
    NSUInteger count = CGPDFDocumentGetNumberOfPages(document);
    NSAssert(count == 1, @"");
    CGPDFPageRef page = CGPDFDocumentGetPage(document, 1);
    CGRect rect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    NSAssert([NSStringFromCGRect(rect) isEqualToString:@"{{0, 0}, {595, 842}}"], @"");
    CGPDFDocumentRelease(document);
}

- (void)test {
    NSURL *plainURL = [[NSBundle bundleForClass:self.class] URLForResource:@"test" withExtension:@"pdf"];
    CGDataProviderRef urlProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)plainURL);
    [self checkProvider:urlProvider];
    CGDataProviderRelease(urlProvider);

    NSURL *cryptoURL = [[NSBundle bundleForClass:self.class] URLForResource:@"test" withExtension:@"pdf.crypto"];
    NWIOCryptoAccess *access = [[NWIOCryptoAccess alloc] initWithInputURL:cryptoURL outputURL:nil append:NO];
    // crypto doesn't (yet) know how long the file is
    access.inputLength = 1114;
    CGDataProviderRef accessProvider = NWIOCGDataProviderCreateWithAccess(access);
    [self checkProvider:accessProvider];
    CGDataProviderRelease(accessProvider);

    NSURL *deflateURL = [[NSBundle bundleForClass:self.class] URLForResource:@"test" withExtension:@"pdf.deflate"];
    NWIOStream *stream = [[NWIODeflateStream alloc] initWithMappedInputURL:deflateURL mappedOutputURL:nil append:NO];
    CGDataProviderRef streamProvider = NWIOCGDataProviderCreateWithStream(stream);
    [self checkProvider:streamProvider];
    CGDataProviderRelease(streamProvider);
}

@end
