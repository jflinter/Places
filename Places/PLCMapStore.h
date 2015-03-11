//
//  PLCMapStore.h
//  Places
//
//  Created by Jack Flintermann on 5/22/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLCMap;

@interface PLCMapStore : NSObject

+ (void)createDefaultMapIfNecessary;
+ (NSArray *)allMaps;
+ (PLCMap *)createMapWithName:(NSString *)name;
+ (void)deleteMap:(PLCMap *)map;
+ (void)updateMap:(PLCMap *)map withName:(NSString *)name;

@end
