//
//  PLCGeocodingService.m
//  Places
//
//  Created by Jack Flintermann on 7/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCGeocodingService.h"
#import "PLCGeocodingOperation.h"
#import <Reachability/Reachability.h>

@interface PLCGeocodingService ()
@property (nonatomic, readwrite) NSOperationQueue *operationQueue;
@end

@implementation PLCGeocodingService

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ sharedInstance = [self new]; });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.qualityOfService = NSQualityOfServiceBackground;
        _operationQueue.maxConcurrentOperationCount = 1;
        Reachability *reach = [Reachability reachabilityForInternetConnection];
        [_operationQueue setSuspended:reach.currentReachabilityStatus == NotReachable];
        reach.reachableBlock = ^(Reachability *reachability) { [self.operationQueue setSuspended:NO]; };
        reach.unreachableBlock = ^(Reachability *reachability) { [self.operationQueue setSuspended:YES]; };
        [reach startNotifier];
    }
    return self;
}

- (PLCGeocodingOperation *)reverseGeocodeLocation:(CLLocation *)location completion:(PLCGeocodingCompletionHandler)completion {
    PLCGeocodingCompletionHandler wrapped = ^(NSArray *placemarks, NSError *error) {
        if (error && error.code == kCLErrorNetwork) {
            [self reverseGeocodeLocation:location completion:completion];
            return;
        }
        if (completion) {
            completion(placemarks, error);
        }
    };
    PLCGeocodingOperation *operation = [PLCGeocodingOperation operationWithLocation:location completion:wrapped];
    [self.operationQueue addOperation:operation];
    return operation;
}

@end
