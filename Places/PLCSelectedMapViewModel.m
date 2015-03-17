//
//  PLCSelectedMapViewModel.m
//  Places
//
//  Created by Jack Flintermann on 3/16/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import "PLCSelectedMapViewModel.h"
#import "PLCMap.h"
#import "PLCPlaceStore.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PLCSelectedMapViewModel()
@property(nonatomic)PLCMap *map;
@property(nonatomic)RACSignal *placesSignal;
@end

@implementation PLCSelectedMapViewModel

- (instancetype)initWithMap:(PLCMap *)map {
    self = [super init];
    if (self) {
        _map = map;
        _placesSignal = RACObserve(_map, activePlaces);
    }
    return self;
}

- (void)removePlace:(PLCPlace *)place {
    [PLCPlaceStore removePlace:place];
}

- (PLCPlace *)addPlaceAtCoordinate:(CLLocationCoordinate2D)coordinate {
    return [PLCPlaceStore insertPlaceOntoMap:self.map atCoordinate:coordinate];
}

@end
