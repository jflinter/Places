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

@interface PLCPlaceStore()<NSFetchedResultsControllerDelegate>
@property(strong, nonatomic)NSFetchedResultsController *fetchedResultsController;
@end

@implementation PLCPlaceStore

- (id) init {
    self = [super init];
    if (self) {
        BOOL success = [self.fetchedResultsController performFetch:nil];
        if (!success) {
            abort();
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentMapChanged:) name:PLCCurrentMapDidChangeNotification object:nil];
    }
    return self;
}

- (void)currentMapChanged:(NSNotification *)notification {
    self.fetchedResultsController.fetchRequest.predicate = [self placePredicate];
    [self.fetchedResultsController performFetch:nil];
}

- (NSArray *)allPlaces {
    return self.fetchedResultsController.fetchedObjects;
}

- (PLCPlace *) insertPlaceAtCoordinate:(CLLocationCoordinate2D)coordinate {
    PLCPlace *place = [PLCPlace insertInManagedObjectContext:[self managedObjectContext]];
    place.coordinate = coordinate;
    place.map = [[PLCMapStore sharedInstance] selectedMap];
    [self save];
    return place;
}

- (void) removePlace:(PLCPlace *)place {
    place.deletedAt = [NSDate date];
    [self save];
}

- (void) save {
    NSError *error;
    [[self managedObjectContext] save:&error];
    if (error) {
        abort();
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(PLCPlace *)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    if (type == NSFetchedResultsChangeInsert) {
        [self.delegate placeStore:self didInsertPlace:anObject];
    }
    if (type == NSFetchedResultsChangeDelete) {
        [self.delegate placeStore:self didRemovePlace:anObject];
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
    NSPredicate *mapPredicate = [NSPredicate predicateWithFormat:@"map.name == %@", [PLCMapStore sharedInstance].selectedMap.name];
    return [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:@[notDeletedPredicate, mapPredicate]];
}

- (NSManagedObjectContext *)managedObjectContext {
    return [PLCDatabase sharedDatabase].mainContext;
}

@end
