//
//  PLCMapStore.h
//  Places
//
//  Created by Jack Flintermann on 5/22/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLCMap, PLCMapStore, PLCPlaceStore;

@interface PLCMapStore : NSObject

+ (instancetype)sharedInstance;

@property(nonatomic, readonly)NSArray *maps;
+ (PLCMap *)createMapWithName:(NSString *)name;
+ (void)deleteMap:(PLCMap *)map;
+ (void)updateMap:(PLCMap *)map withName:(NSString *)name;






// deprecated
@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger numberOfMaps;
- (PLCMap *)mapAtIndex:(NSUInteger)index;
- (void)deleteMapAtIndex:(NSUInteger)index;
@property (nonatomic, strong) PLCMap *selectedMap;
- (void)registerDelegate:(id<NSFetchedResultsControllerDelegate>)delegate;
- (void)unregisterDelegate:(id<NSFetchedResultsControllerDelegate>)delegate;

@end
