//
//  PLCGeocodingService.h
//  Places
//
//  Created by Jack Flintermann on 7/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLCGeocodingOperation;

typedef void (^PLCGeocodingCompletionHandler)(NSArray *placemarks, NSError *error);

@interface PLCGeocodingService : NSObject

+ (instancetype)sharedInstance;
- (PLCGeocodingOperation *)reverseGeocodeLocation:(CLLocation *)location
                                completion:(PLCGeocodingCompletionHandler)completion;

@end
