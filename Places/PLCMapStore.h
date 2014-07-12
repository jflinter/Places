//
//  PLCMapStore.h
//  Places
//
//  Created by Jack Flintermann on 5/22/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const PLCCurrentMapDidChangeNotification;

@class PLCMap, PLCMapStore;

@protocol PLCMapStoreDelegate <NSObject>
- (void)mapStore:(PLCMapStore *)store didChangeMap:(PLCMap *)map;
@end

@interface PLCMapStore : NSObject

+ (instancetype)sharedInstance;
- (NSArray *)allMaps;
- (PLCMap *)mapAtIndex:(NSUInteger)index;
- (PLCMap *)insertMapWithName:(NSString *)name;
@property(nonatomic, strong)PLCMap *selectedMap;
@property(nonatomic, weak)id<PLCMapStoreDelegate> delegate;

@end
