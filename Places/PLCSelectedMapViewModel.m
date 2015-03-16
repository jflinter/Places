//
//  PLCSelectedMapViewModel.m
//  Places
//
//  Created by Jack Flintermann on 3/16/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import "PLCSelectedMapViewModel.h"
#import "PLCMap.h"

@interface PLCSelectedMapViewModel()
@property(nonatomic)PLCMap *map;
@property(nonatomic)NSSet *places;
@property(nonatomic)TTTLocationFormatter *formatter;
@end

@implementation PLCSelectedMapViewModel

- (instancetype)initWithMap:(PLCMap *)map {
    self = [super init];
    if (self) {
        _map = map;
        _places = [NSSet setWithArray:map.activePlaces];
        _formatter = [[TTTLocationFormatter alloc] init];
        _formatter.bearingStyle = TTTBearingAbbreviationWordStyle;
    }
    return self;
}

@end
