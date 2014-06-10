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

@interface PLCPlaceStore()<NSFetchedResultsControllerDelegate>
@property(strong, nonatomic)NSFetchedResultsController *fetchedResultsController;
@end

@implementation PLCPlaceStore

+(instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (id) init {
    self = [super init];
    if (self) {
        self.fetchedResultsController.fetchRequest.predicate = [self placePredicate];
        BOOL success = [self.fetchedResultsController performFetch:nil];
        if (!success) {
            abort();
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentMapChanged:) name:PLCCurrentMapDidChangeNotification object:[PLCMapStore sharedInstance]];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)currentMapChanged:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (PLCPlace *place in self.fetchedResultsController.fetchedObjects) {
            [self.delegate placeStore:self didRemovePlace:place];
        }
        self.fetchedResultsController.fetchRequest.predicate = [self placePredicate];
        [self.fetchedResultsController performFetch:nil];
        for (PLCPlace *place in self.fetchedResultsController.fetchedObjects) {
            [self.delegate placeStore:self didInsertPlace:place new:NO];
        }
    });
}

- (NSArray *)allPlaces {
    return self.fetchedResultsController.fetchedObjects;
}

- (PLCPlace *) insertPlaceAtCoordinate:(CLLocationCoordinate2D)coordinate {
    PLCPlace *place = [PLCPlace insertInManagedObjectContext:[self managedObjectContext]];
    place.coordinate = coordinate;
    place.map = [[PLCMapStore sharedInstance] selectedMap];
    [self save];
    [self.delegate placeStore:self didInsertPlace:place new:YES];
    return place;
}

- (void) removePlace:(PLCPlace *)place {
    place.deletedAt = [NSDate date];
    [self save];
    [self.delegate placeStore:self didRemovePlace:place];
}

- (void) save {
    NSError *error;
    for (PLCPlace *place in [[self managedObjectContext] insertedObjects]) {
        if ([place isKindOfClass:[PLCPlace class]]) {
            [[Firebase placeClientForPlace:place] setValue:[place firebaseObject]];
        }
    }
    for (PLCPlace *place in [[self managedObjectContext] updatedObjects]) {
        if ([place isKindOfClass:[PLCPlace class]]) {
            [[Firebase placeClientForPlace:place] setValue:[place firebaseObject]];
        }
    }
    for (PLCPlace *place in [[self managedObjectContext] deletedObjects]) {
        if ([place isKindOfClass:[PLCPlace class]]) {
            [[Firebase placeClientForPlace:place] removeValue];
        }
    }
    [[self managedObjectContext] save:&error];
    if (error) {
        abort();
    }
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequest] managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}

- (NSFetchRequest *)fetchRequest
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[PLCPlace entityName]];
    fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:PLCPlaceAttributes.latitude ascending:YES], [NSSortDescriptor sortDescriptorWithKey:PLCPlaceAttributes.longitude ascending:YES] ];
    fetchRequest.predicate = [self placePredicate];
    return fetchRequest;
}

- (NSPredicate *)placePredicate {
    NSExpression *nilExpression = [NSExpression expressionForConstantValue:[NSNull null]];
    NSExpression *deletedAtExpression = [NSExpression expressionForKeyPath:PLCPlaceAttributes.deletedAt];
    NSPredicate *notDeletedPredicate = [NSComparisonPredicate predicateWithLeftExpression:deletedAtExpression rightExpression:nilExpression modifier:NSDirectPredicateModifier type:NSEqualToPredicateOperatorType options:0];
    NSExpression *selectedExpression = [NSExpression expressionForKeyPath:@"map.selected"];
    NSExpression *yesExpression = [NSExpression expressionForConstantValue:@YES];
    NSPredicate *mapPredicate = [NSComparisonPredicate predicateWithLeftExpression:selectedExpression rightExpression:yesExpression modifier:0 type:NSEqualToPredicateOperatorType options:0];
    return [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:@[notDeletedPredicate, mapPredicate]];
}

- (NSManagedObjectContext *)managedObjectContext {
    return [PLCDatabase sharedDatabase].mainContext;
}

@end
