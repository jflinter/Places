//
//  PLCGeocodingOperation.h
//  Places
//
//  Created by Jack Flintermann on 7/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLCGeocodingService.h"

@interface PLCGeocodingOperation : NSOperation

@property(nonatomic, readonly)CLLocation *location;
@property(nonatomic, copy, readonly)PLCGeocodingCompletionHandler completion;

+ (instancetype)operationWithLocation:(CLLocation *)location completion:(PLCGeocodingCompletionHandler)completion;

@end
