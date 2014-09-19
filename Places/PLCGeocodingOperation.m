//
//  PLCGeocodingOperation.m
//  Places
//
//  Created by Jack Flintermann on 7/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCGeocodingOperation.h"

@interface PLCGeocodingOperation()
@property(nonatomic)CLLocation *location;
@property(nonatomic, copy)PLCGeocodingCompletionHandler completion;
@property(nonatomic)CLGeocoder *geocoder;
@property(nonatomic)BOOL plcIsExecuting, plcIsFinished;
@end

@implementation PLCGeocodingOperation

+ (instancetype)operationWithLocation:(CLLocation *)location completion:(PLCGeocodingCompletionHandler)completion {
    PLCGeocodingOperation *operation = [PLCGeocodingOperation new];
    operation.location = location;
    operation.completion = completion;
    return operation;
}

- (id)init {
    self = [super init];
    if (self) {
        _geocoder = [CLGeocoder new];
    }
    return self;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)start {
    if ([self isCancelled]) {
        [self finish];
        return;
    }
    self.executing = YES;
    [self.geocoder reverseGeocodeLocation:self.location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (self.completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completion(placemarks, error);
            });
        }
        [self finish];
    }];
}

-(void)finish {
    self.executing = NO;
    self.finished = YES;
}

- (void)cancel {
    [super cancel];
    [self.geocoder cancelGeocode];
    self.geocoder = [CLGeocoder new];
}

- (BOOL)isFinished {
    return self.plcIsFinished;
}

- (BOOL)isExecuting {
    return self.plcIsExecuting;
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _plcIsExecuting = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _plcIsFinished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

@end
