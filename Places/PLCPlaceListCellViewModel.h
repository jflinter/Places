//
//  PLCPlaceListCellViewModel.h
//  Places
//
//  Created by Jack Flintermann on 3/17/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLCPlace, RACSignal;

@interface PLCPlaceListCellViewModel : NSObject

- (instancetype)initWithPlace:(PLCPlace *)place;

@property(nonatomic)PLCPlace *selectedPlace;
@property(nonatomic)CLLocation *currentLocation;
@property(nonatomic, readonly)RACSignal *titleSignal;
@property(nonatomic, readonly)RACSignal *subtitleSignal;
@property(nonatomic, readonly)RACSignal *selectedSignal;

@end
