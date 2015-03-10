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
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) PLCMapStore *mapStore;
@property (nonatomic) NSArray *placesViewModels;
@end

@implementation PLCPlaceStore

- (instancetype)initWithMapStore:(PLCMapStore *)mapStore {
    self = [super init];
    if (self) {
        _placesViewModels = [@[] mutableCopy];
        _placesSignal = RACObserve(self, placesViewModels);
        _mapStore = mapStore;
        self.fetchedResultsController.fetchRequest.predicate = [self placePredicate];
        BOOL success = [self.fetchedResultsController performFetch:nil];
        if (!success) {
            abort();
        }
        [RACObserve(mapStore, selectedMap) subscribeNext:^(__unused id x) {
          dispatch_async(dispatch_get_main_queue(), ^{
            self.fetchedResultsController.fetchRequest.predicate = [self placePredicate];
            [self.fetchedResultsController performFetch:nil];
            self.placesViewModels = [self.fetchedResultsController.fetchedObjects.rac_sequence map:^id(PLCPlace *value) {
              return [[PLCPlaceViewModel alloc] initWithPlace:value];
            }].array;
          });
        }];
    }
    return self;
}

- (PLCPlaceViewModel *)insertPlaceAtCoordinate:(CLLocationCoordinate2D)coordinate {
    PLCPlace *place = [PLCPlace insertInManagedObjectContext:[self.class managedObjectContext]];
    place.coordinate = coordinate;
    PLCMap *map = [[PLCMapStore sharedInstance] selectedMap];
    [map addPlacesObject:place];
    place.map = map;
    
    [self save];
    PLCPlaceViewModel *viewModel = [[PLCPlaceViewModel alloc] initWithPlace:place];
    self.placesViewModels = [self.placesViewModels arrayByAddingObject:viewModel];
    return viewModel;
}

- (void)removePlace:(PLCPlaceViewModel *)place {
    if (self.selectedPlace == place) {
        self.selectedPlace = nil;
    }
    PLCMap *map = [[PLCMapStore sharedInstance] selectedMap];
    PLCPlace *placeObject = [[map.places filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"uuid == %@", place.uuid]] anyObject];
    placeObject.deletedAt = [NSDate date];
    [self save];
    NSMutableArray *array = [self.placesViewModels mutableCopy];
    [array removeObject:place];
    self.placesViewModels = [array copy];
}

- (void)save {
    for (PLCPlace *place in [[self.class managedObjectContext] insertedObjects]) {
        if ([place isKindOfClass:[PLCPlace class]] && CLLocationCoordinate2DIsValid(place.coordinate)) {
            [[Firebase placeClientForPlace:place] setValue:[place firebaseObject]];
        }
    }
    for (PLCPlace *place in [[self.class managedObjectContext] updatedObjects]) {
        if ([place isKindOfClass:[PLCPlace class]] && CLLocationCoordinate2DIsValid(place.coordinate)) {
            [[Firebase placeClientForPlace:place] setValue:[place firebaseObject]];
        }
    }
    for (PLCPlace *place in [[self.class managedObjectContext] deletedObjects]) {
        if ([place isKindOfClass:[PLCPlace class]]) {
            [[Firebase placeClientForPlace:place] removeValue];
        }
    }
    if (![[self.class managedObjectContext] save:nil]) {
        abort();
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequest]
                                                                        managedObjectContext:[self.class managedObjectContext]
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    }
    return _fetchedResultsController;
}

- (NSFetchRequest *)fetchRequest {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[PLCPlace entityName]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"latitude != -180 && longitude != -180"];
    fetchRequest.sortDescriptors = @[
        [NSSortDescriptor sortDescriptorWithKey:PLCPlaceAttributes.latitude ascending:YES],
        [NSSortDescriptor sortDescriptorWithKey:PLCPlaceAttributes.longitude ascending:YES]
    ];
    fetchRequest.predicate = [self placePredicate];
    return fetchRequest;
}

- (NSPredicate *)placePredicate {
    NSExpression *nilExpression = [NSExpression expressionForConstantValue:[NSNull null]];
    NSExpression *deletedAtExpression = [NSExpression expressionForKeyPath:PLCPlaceAttributes.deletedAt];
    NSPredicate *notDeletedPredicate = [NSComparisonPredicate predicateWithLeftExpression:deletedAtExpression
                                                                          rightExpression:nilExpression
                                                                                 modifier:NSDirectPredicateModifier
                                                                                     type:NSEqualToPredicateOperatorType
                                                                                  options:0];
    NSString *keyPath = [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(map)), NSStringFromSelector(@selector(selected))];
    NSExpression *selectedExpression = [NSExpression expressionForKeyPath:keyPath];
    NSExpression *yesExpression = [NSExpression expressionForConstantValue:@YES];
    NSPredicate *mapPredicate = [NSComparisonPredicate predicateWithLeftExpression:selectedExpression
                                                                   rightExpression:yesExpression
                                                                          modifier:0
                                                                              type:NSEqualToPredicateOperatorType
                                                                           options:0];
    return [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:@[notDeletedPredicate, mapPredicate]];
}

- (NSManagedObjectContext *)managedObjectContext {
    return [PLCDatabase sharedDatabase].mainContext;
}

@end
