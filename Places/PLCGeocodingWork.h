//
//  PLCGeocodingWork.h
//  Places
//
//  Created by Jack Flintermann on 12/28/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "PLCPersistentQueue.h"

@interface PLCGeocodingWork : MTLModel<PLCAsynchronousWork>
- (instancetype)initWithLocation:(CLLocation *)location placeId:(NSString *)placeId;
@end
