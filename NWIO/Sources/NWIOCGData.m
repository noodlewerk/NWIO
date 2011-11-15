//
//  NWIOCGData.m
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

#import "NWIOCGData.h"


#pragma mark - CGDataProvider from stream

static size_t NWIOCGDataProviderGetBytesCallback(void *stream, void *buffer, size_t length) {
    return [(__bridge NWIOStream *)stream read:buffer length:length];
}

static void NWIOCGDataProviderReleaseInfoCallbackStream(void *stream) {
    NWIOStream *s = (__bridge_transfer NWIOStream *)stream;
    [s class];
}

static void NWIOCGDataProviderRewindCallback(void *stream) {
    [(__bridge NWIOStream *)stream rewindRead];
}

static off_t NWIOCGDataProviderSkipForwardCallback(void *stream, off_t count) {
    return [(__bridge NWIOStream *)stream read:0 length:count];
}

CGDataProviderRef NWIOCGDataProviderCreateWithStream(NWIOStream *stream) {
    const CGDataProviderSequentialCallbacks callbacks = {0, &NWIOCGDataProviderGetBytesCallback, &NWIOCGDataProviderSkipForwardCallback, &NWIOCGDataProviderRewindCallback, &NWIOCGDataProviderReleaseInfoCallbackStream};
    return CGDataProviderCreateSequential((__bridge_retained void *)stream, &callbacks);
}


#pragma mark - CGDataConsumer from stream

static size_t NWIOCGDataConsumerPutBytesCallback(void *stream, const void *buffer, size_t length) {
    return [(__bridge NWIOStream *)stream write:buffer length:length];
}

static void NWIOCGDataConsumerReleaseInfoCallback(void *stream) {
    NWIOStream *s = (__bridge_transfer NWIOStream *)stream;
    [s class];
}

CGDataConsumerRef NWIOCGDataConsumerCreateWithStream(NWIOStream *stream) {
    const CGDataConsumerCallbacks callbacks = {&NWIOCGDataConsumerPutBytesCallback, &NWIOCGDataConsumerReleaseInfoCallback};
    return CGDataConsumerCreate((__bridge_retained void *)stream, &callbacks);
}


#pragma mark - CGDataProvider from access

static size_t NWIOCGDataProviderGetBytesAtPositionCallback(void *access, void *buffer, off_t location, size_t length) {
    return [(__bridge NWIOAccess *)access read:buffer range:NSMakeRange(location, length)];
}

static void NWIOCGDataProviderReleaseInfoCallbackAccess(void *access) {
    NWIOAccess *a = (__bridge_transfer NWIOAccess *)access;
    [a class];
}

CGDataProviderRef NWIOCGDataProviderCreateWithAccess(NWIOAccess *access) {
    const CGDataProviderDirectCallbacks callbacks = {0, NULL, NULL, &NWIOCGDataProviderGetBytesAtPositionCallback, &NWIOCGDataProviderReleaseInfoCallbackAccess};
    return CGDataProviderCreateDirect((__bridge_retained void *)access, access.inputLength, &callbacks);
}
