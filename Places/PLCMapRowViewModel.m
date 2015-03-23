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
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PLCMapRowViewModel()
@end

@implementation PLCMapRowViewModel

- (instancetype)initWithMap:(PLCMap *)map {
    self = [super init];
    if (self) {
        _selected = ([PLCSelectedMapCache sharedInstance].selectedMap == map);
        RAC(self, title) = RACObserve(map, name);
    }
    return self;
}

- (CGFloat)rowHeight {
    return self.detailShown ? 88 : 44;
}

@end
