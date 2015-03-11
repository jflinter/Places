//
//  PLCMapRowViewModel.m
//  Places
//
//  Created by Jack Flintermann on 3/11/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import "PLCMapRowViewModel.h"
#import "PLCMapStore.h"
#import "PLCSelectedMapCache.h"
#import "PLCMap.h"

@interface PLCMapRowViewModel()
@property(nonatomic)PLCMap *map;
@end

@implementation PLCMapRowViewModel

- (instancetype)initWithMap:(PLCMap *)map {
    self = [super init];
    if (self) {
        _map = map;
        _selected = ([PLCSelectedMapCache sharedInstance].selectedMap == self.map);
        _title = map.name;
    }
    return self;
}

@end
