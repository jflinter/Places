//
//  PLCPlaceStore.h
//  Places
//
//  Created by Jack Flintermann on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLCMapStore.h"

@class PLCPlace, PLCPlaceStore;

extern NSString * const PLCPlaceStoreWillAddPlaceNotification;

@interface PLCPlaceStore : NSObject

+ (PLCPlace *)insertPlaceOntoMap:(PLCMap *)map atCoordinate:(CLLocationCoordinate2D)coordinate;
+ (void)updatePlace:(PLCPlace *)place withCoordinate:(CLLocationCoordinate2D)coordinate;
+ (void)updatePlace:(PLCPlace *)place withCaption:(NSString *)caption;
+ (void)removePlace:(PLCPlace *)place;

@end
