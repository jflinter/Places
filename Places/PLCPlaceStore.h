//
//  PLCPlaceStore.h
//  Places
//
//  Created by Jack Flintermann on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLCPlace, PLCPlaceStore;

@protocol PLCPlaceStoreDelegate<NSObject>
- (void)placeStore:(PLCPlaceStore *)store didInsertPlace:(PLCPlace *)place new:(BOOL)isNew;
- (void)placeStore:(PLCPlaceStore *)store didRemovePlace:(PLCPlace *)place;
@end

@interface PLCPlaceStore : NSObject

@property (readonly, nonatomic) NSArray *allPlaces;
@property (weak, nonatomic) id<PLCPlaceStoreDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)save;

- (PLCPlace *)insertPlaceAtCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)removePlace:(PLCPlace *)place;

@end
