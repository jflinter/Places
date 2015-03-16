//
//  PLCSelectedMapViewModel.h
//  Places
//
//  Created by Jack Flintermann on 3/16/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLCPlace, PLCMap;

@interface PLCSelectedMapViewModel : NSObject

@property(nonatomic, readonly)NSSet *places;
@property(nonatomic)CLLocation *currentLocation;
@property(nonatomic)PLCPlace *selectedPlace;

- (instancetype)initWithMap:(PLCMap *)map;

@end
