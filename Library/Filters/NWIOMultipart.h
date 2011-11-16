//
//  NWIOMultipart.h
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

#import "NWIOIdentity.h"

/**
 * Wraps a stream of file data as part of an HTTP request with content type 'multipart/form-data'.
 */
@interface NWIOMultipartStream : NWIOIdentityStream

/**
 * The form key for the file content entry.
 *
 * `Content-Disposition: form-data; name="<contentFormKey>"; filename="garbage.pdf"`
 */
@property (nonatomic, strong) NSString *contentFormKey;

/**
 * The form filename for the file content entry.
 *
 * `Content-Disposition: form-data; name="file"; filename="<contentFilename>"`
 */
@property (nonatomic, strong) NSString *contentFilename;

/**
 * The boundary text that is used to separate fields. Should not occur anywhere else in the HTTP body. If left blank, a boundary will be generated upon calling [compose].
 *
 * NB: the value of boundary should be mentioned in the HTTP header: `Content-Type: multipart/form-data; boundary=<bounary>`
 */
@property (nonatomic, strong) NSString *boundary;

/**
 * A plain dictionary with NSString keys, with one entry for each form parameter.
 */
@property (nonatomic, strong) NSDictionary *parameters;

/**
 * The length of the stream without the content, i.e. the size of the form head and foot. This property is set in [compose]. Should be used to compute the content length, as set in the HTTP header: `Content-Length: <formDataLengt + contentLength>`
 */
@property (nonatomic, assign, readonly) NSUInteger formDataLength;

/**
 * Composes the static form data based on properties of this multipart stream. Generates a boundary string if none was set.
 *
 * NB: should be invoked before performing any I/O on this stream.
 */
- (void)compose;

/**
 * Configures the request to upload from this stream.
 * @param request Any request, on which HTTPMethod, HTTPBodyStream, Content-Type, and Content-Length is set.
 * @param streamLength The length of the filtered stream.
 */
- (void)configureRequest:(NSMutableURLRequest *)request streamLength:(NSUInteger)streamLength;

@end
