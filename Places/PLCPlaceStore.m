//
//  PLCPlaceStore.m
//  Places
//
//  Created by Jack Flintermann on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPlace.h"
#import "PLCPlaceStore.h"
#import "PLCDatabase.h"

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
    }
    return self;
}

- (NSArray *)allPlaces {
    return self.fetchedResultsController.fetchedObjects;
}

- (void) insertPlaceAtCoordinate:(CLLocationCoordinate2D)coordinate {
    PLCPlace *place = [PLCPlace insertInManagedObjectContext:[self managedObjectContext]];
    place.coordinate = coordinate;
    [self save];
    [self.delegate placeStore:self didInsertPlace:place];
}

- (void) removePlace:(PLCPlace *)place {
    [place removeObserver:self forKeyPath:@"coordinate"];
    [[self managedObjectContext] deleteObject:place];
    [self save];
    [self.delegate placeStore:self didRemovePlace:place];
}

- (void) save {
    NSError *error;
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
    return fetchRequest;
}

- (NSManagedObjectContext *)managedObjectContext {
    return [PLCDatabase sharedDatabase].mainContext;
}

@end
