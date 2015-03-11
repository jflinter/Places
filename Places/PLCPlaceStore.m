//
//  PLCPlaceStore.m
//  Places
//
//  Created by Jack Flintermann on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPlace.h"
#import "PLCPlaceStore.h"
#import "PLCMapStore.h"
#import "PLCDatabase.h"
#import "PLCMap.h"
#import <Firebase/Firebase.h>
#import "Firebase+Places.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PLCPlaceStore ()
@property (nonatomic) PLCMapStore *mapStore;
@end

@implementation PLCPlaceStore

+ (PLCPlace *)insertPlaceOntoMap:(PLCMap *)map atCoordinate:(CLLocationCoordinate2D)coordinate {
    PLCPlace *place = [PLCPlace insertInManagedObjectContext:[self.class managedObjectContext]];
    place.coordinate = coordinate;
    [map addPlacesObject:place];
    place.map = map;
    [[self managedObjectContext] save:nil];
    [[Firebase placeClientForPlace:place] setValue:[place firebaseObject]];
    return place;
}

+ (void)updatePlace:(PLCPlace *)place withCoordinate:(CLLocationCoordinate2D)coordinate {
    place.coordinate = coordinate;
    [[self managedObjectContext] save:nil];
    [[Firebase placeClientForPlace:place] setValue:[place firebaseObject]];
}

+ (void)updatePlace:(PLCPlace *)place withCaption:(NSString *)caption {
    place.caption = caption;
    [[self managedObjectContext] save:nil];
    [[Firebase placeClientForPlace:place] setValue:[place firebaseObject]];
}

+ (void)removePlace:(PLCPlace *)place {
    place.deletedAt = [NSDate date];
    [[self managedObjectContext] save:nil];
    place.map.places = place.map.places;
    [[Firebase placeClientForPlace:place] setValue:[place firebaseObject]];
}

+ (NSManagedObjectContext *)managedObjectContext {
    return [PLCDatabase sharedDatabase].mainContext;
}

@end
