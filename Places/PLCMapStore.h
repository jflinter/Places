//
//  PLCMapStore.h
//  Places
//
//  Created by Jack Flintermann on 5/22/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const PLCCurrentMapDidChangeNotification;

@class PLCMap, PLCMapStore, PLCPlaceStore;

@interface PLCMapStore : NSObject

+ (instancetype)sharedInstance;

@property(nonatomic, readonly)PLCPlaceStore *placeStore;

@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger numberOfMaps;
- (PLCMap *)mapAtIndex:(NSUInteger)index;
- (PLCMap *)insertMapWithName:(NSString *)name;
- (void)updateMap:(PLCMap *)map withName:(NSString *)name;
- (void)deleteMapAtIndex:(NSUInteger)index;
@property (nonatomic, strong) PLCMap *selectedMap;
- (void)registerDelegate:(id<NSFetchedResultsControllerDelegate>)delegate;
- (void)unregisterDelegate:(id<NSFetchedResultsControllerDelegate>)delegate;
- (void)save;

- (void)downloadMapsForUserId:(NSString *)userId;

@end
