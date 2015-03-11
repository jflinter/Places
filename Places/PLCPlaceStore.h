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

@interface PLCPlaceStore : NSObject

+ (PLCPlace *)insertPlaceOntoMap:(PLCMap *)map atCoordinate:(CLLocationCoordinate2D)coordinate;
+ (void)updatePlace:(PLCPlace *)place onMap:(PLCMap *)map withCoordinate:(CLLocationCoordinate2D)coordinate;
+ (void)updatePlace:(PLCPlace *)place onMap:(PLCMap *)map withCaption:(NSString *)caption;
+ (void)removePlace:(PLCPlace *)place fromMap:(PLCMap *)map;

@end
