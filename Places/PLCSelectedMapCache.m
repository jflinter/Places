//
//  PLCSelectedMapCache.m
//  Places
//
//  Created by Jack Flintermann on 3/10/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import "PLCSelectedMapCache.h"
#import "PLCMapStore.h"
#import "PLCMap.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PLCSelectedMapCache()
@property(nonatomic)NSString *savedMapId;
@end

@implementation PLCSelectedMapCache

+ (instancetype) sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *previousId = [self savedMapId];
        NSArray *allMaps = [PLCMapStore allMaps];
        NSArray *availableMaps = [allMaps.rac_sequence filter:^BOOL(PLCMap *map) {
            return [map.uuid isEqualToString:previousId];
        }].array;
        _selectedMap = availableMaps.firstObject ?: allMaps.firstObject;
        [[[RACObserve(self, selectedMap) map:^id(PLCMap *map) {
            return RACObserve(map, deletedAt);
        }] switchToLatest] subscribeNext:^(NSDate *deletedAt) {
            if (deletedAt) {
                PLCMap *currentMap = self.selectedMap;
                NSArray *maps = [PLCMapStore allMaps];
                NSArray *names = [maps.rac_sequence map:^id(PLCMap *map) {
                    return map.name;
                }].array;
                NSComparator comparator = ^NSComparisonResult(NSString *obj1, NSString *obj2) {
                    return [obj1 caseInsensitiveCompare:obj2];
                };
                NSInteger index = [names indexOfObject:currentMap.name
                                         inSortedRange:(NSRange){0, names.count}
                                               options:NSBinarySearchingInsertionIndex
                                       usingComparator:comparator];
                NSInteger newIndex = (index == (NSInteger)names.count) ? names.count - 1 : index;
                self.selectedMap = maps[newIndex];
            }
        }];
    }
    return self;
}

- (void)setSelectedMap:(PLCMap *)selectedMap {
    _selectedMap = selectedMap;
    self.savedMapId = selectedMap.uuid;
}

- (NSString *)savedMapId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"PLCSelectedMapCacheMapID"];
}

- (void)setSavedMapId:(NSString *)savedMapId {
    [[NSUserDefaults standardUserDefaults] setObject:savedMapId forKey:@"PLCSelectedMapCacheMapID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
