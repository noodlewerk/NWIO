//
//  NWIOStat.m
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

#import "NWIOStat.h"


@implementation NWIOStatInteger {
    long int sum;
    long long int squareSum;
}

@synthesize count;


#pragma mark - Operations

- (void)count:(NSUInteger)value {
    count++;
    sum += value;
    squareSum += value * value;
}

- (void)uncount:(NSUInteger)value {
    count--;
    sum -= value < sum ? value : sum;
    // yes, it's not correct, but what else?
    squareSum -= 3 * value * value < squareSum ? 3 * value * value : squareSum;
}

- (NSUInteger)average {
    return sum / count;
}

- (long long)variance {
    return (squareSum - (long long int)sum * sum / count) / count;
}

- (NSUInteger)deviation {
    return (NSUInteger)sqrtl(self.variance);
}


#pragma mark - Misc

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: count:%i average:%i deviation:%i>", self.class, count, self.average, self.deviation];
}

@end



@implementation NWIOStatStream

@synthesize lengthStat;


#pragma mark - Object life cycle

- (id)initWithStream:(NWIOStream *)_stream {
    self = [super initWithStream:_stream];
    if (self) {
        lengthStat = [[NWIOStatInteger alloc] init];
    }
    return self;
}


#pragma mark - NWIOStream subclass

- (NSUInteger)read:(void *)buffer length:(NSUInteger)length {
    NSUInteger result = [stream read:buffer length:length];
    if (result > 0) {
        [lengthStat count:result];
    }
    return result;
}

- (NSUInteger)readable:(const void **)buffer {
    NSUInteger result = [stream readable:buffer];
    if (result > 0) {
        [lengthStat count:result];
    }
    return result;
}

- (NSUInteger)write:(const void *)buffer length:(NSUInteger)length {
    NSUInteger result = [stream write:buffer length:length];
    if (result > 0) {
        [lengthStat count:result];
    }
    return result;
}

- (NSUInteger)writable:(void **)buffer {
    NSUInteger result = [stream writable:buffer];
    if (result > 0) {
        [lengthStat count:result];
    }
    return result;
}

- (void)unwritable:(NSUInteger)length {
    [stream unwritable:length];
    [lengthStat uncount:length];
}


#pragma mark - Misc

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: count:%i avg-length:%i>", self.class, lengthStat.count, lengthStat.average];
}

@end



@implementation NWIOStatAccess

@synthesize lengthStat, locationStat;


#pragma mark - Object life cycle

- (id)initWithAccess:(NWIOAccess *)_access {
    self = [super initWithAccess:_access];
    if (self) {
        locationStat = [[NWIOStatInteger alloc] init];
        lengthStat = [[NWIOStatInteger alloc] init];
    }
    return self;
}


#pragma mark - NWIOAccess subclass

- (NSUInteger)read:(void *)buffer range:(NSRange)range {
    NSUInteger result = [access read:buffer range:range];
    [locationStat count:range.location];
    [lengthStat count:result];
    return result;
}

- (NSUInteger)readable:(const void **)buffer location:(NSUInteger)location {
    NSUInteger result = [access readable:buffer location:location];
    [locationStat count:location];
    [lengthStat count:result];
    return result;
}

- (NSUInteger)write:(const void *)buffer range:(NSRange)range {
    NSUInteger result = [access write:buffer range:range];
    [locationStat count:range.location];
    [lengthStat count:result];
    return result;
}

- (NSUInteger)writable:(void **)buffer location:(NSUInteger)location {
    NSUInteger result = [access writable:buffer location:location];
    [locationStat count:location];
    [lengthStat count:result];
    return result;
}


#pragma mark - Misc

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: count:%i avg.location:%i avg.length:%i>", self.class, lengthStat.count, locationStat.count, lengthStat.average];
}

@end