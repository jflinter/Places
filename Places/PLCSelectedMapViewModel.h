//
//  PLCSelectedMapViewModel.h
//  Places
//
//  Created by Jack Flintermann on 3/16/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLCPlace, PLCMap, RACSignal;

@interface PLCSelectedMapViewModel : NSObject

@property(nonatomic, readonly)RACSignal *placesSignal;
@property(nonatomic)CLLocation *currentLocation;
@property(nonatomic)PLCPlace *selectedPlace;

- (instancetype)initWithMap:(PLCMap *)map;

- (PLCPlace *)addPlaceAtCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)removePlace:(PLCPlace *)place;

@end
