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
        if (previousId) {
            _selectedMap = [[PLCMapStore allMaps].rac_sequence filter:^BOOL(PLCMap *map) {
                return map.uuid = previousId;
            }].array.firstObject;
        } else {
            _selectedMap = [PLCMapStore allMaps].firstObject;
        }
    }
    return self;
}

- (NSString *)savedMapId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"PLCSelectedMapCacheMapID"];
}

- (void)setSavedMapId:(NSString *)savedMapId {
    [[NSUserDefaults standardUserDefaults] setObject:savedMapId forKey:@"PLCSelectedMapCacheMapID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
