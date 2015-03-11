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

- (void)setTitle:(NSString *)title {
    _title = title;
    [PLCMapStore updateMap:self.map withName:title];
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [PLCSelectedMapCache sharedInstance].selectedMap = self.map;
}

- (void)deleteMap {
    if ([PLCMapStore allMaps].count == 1) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Can't delete last map", nil)
                                    message:NSLocalizedString(@"You have to have at least one map. To delete this map, make another map first.", nil)
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        return;
    }
    [PLCMapStore deleteMap:self.map];

}

@end
