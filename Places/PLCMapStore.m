//
//  PLCMapStore.m
//  Places
//
//  Created by Jack Flintermann on 5/22/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCMapStore.h"
#import "PLCPlaceStore.h"
#import "PLCDatabase.h"
#import "PLCMap.h"
#import "PLCUserStore.h"
#import <Firebase/Firebase.h>
#import "Firebase+Places.h"
#import "PLCPlaceStore.h"
#import "PLCPlace.h"

static NSString *const PLCCurrentMapSaveKey = @"PLCCurrentMapSaveKey";
static NSString *const PLCCurrentMapDidChangeNotification = @"PLCCurrentMapDidChangeNotification";

@interface PLCMapStore () <NSFetchedResultsControllerDelegate>
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSMutableArray *delegates;
- (NSArray *)allMaps;
@end

@implementation PLCMapStore

+ (instancetype)sharedInstance {
    static PLCMapStore *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ sharedInstance = [self new]; });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _delegates = [@[] mutableCopy];
        self.selectedMap = [self selectedMap] ?: [self defaultMap];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequest:NO]
                                                                            managedObjectContext:[self managedObjectContext]
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
        self.fetchedResultsController.delegate = self;
        [self.fetchedResultsController performFetch:nil];
    }
    return self;
}

- (NSUInteger)numberOfMaps {
    id<NSFetchedResultsSectionInfo> section = [[self.fetchedResultsController sections] firstObject];
    return [section numberOfObjects];
}

- (NSArray *)notDeletedMaps {
    return self.fetchedResultsController.fetchedObjects;
}

- (NSArray *)allMaps {
    return [[self managedObjectContext] executeFetchRequest:[self fetchRequest:YES] error:nil];
}

- (NSFetchRequest *)fetchRequest:(BOOL)allowDeleted {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[PLCMap entityName]];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:PLCMapAttributes.name ascending:YES]];
    NSExpression *nilExpression = [NSExpression expressionForConstantValue:[NSNull null]];
    NSExpression *deletedAtExpression = [NSExpression expressionForKeyPath:PLCMapAttributes.deletedAt];
    NSPredicate *notDeletedPredicate = [NSComparisonPredicate predicateWithLeftExpression:deletedAtExpression
                                                                          rightExpression:nilExpression
                                                                                 modifier:NSDirectPredicateModifier
                                                                                     type:NSEqualToPredicateOperatorType
                                                                                  options:0];
    if (!allowDeleted) {
        fetchRequest.predicate = notDeletedPredicate;
    }
    return fetchRequest;
}

- (PLCMap *)mapWithUUID:(NSString *)uuid {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[PLCMap entityName]];
    fetchRequest.fetchLimit = 1;
    NSExpression *uuidExpression = [NSExpression expressionForKeyPath:PLCMapAttributes.uuid];
    NSExpression *otherUuidExpression = [NSExpression expressionForConstantValue:uuid];
    fetchRequest.predicate = [NSComparisonPredicate predicateWithLeftExpression:uuidExpression
                                                                rightExpression:otherUuidExpression
                                                                       modifier:0
                                                                           type:NSEqualToPredicateOperatorType
                                                                        options:0];
    return [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] firstObject];
}

- (NSManagedObjectContext *)managedObjectContext {
    return [PLCDatabase sharedDatabase].mainContext;
}

- (PLCMap *)mapAtIndex:(NSUInteger)index {
    return [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:(NSInteger)index inSection:0]];
}

- (PLCMap *)defaultMap {
    return [self insertMapWithName:NSLocalizedString(@"Places", nil)];
}

- (PLCMap *)selectedMap {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[PLCMap entityName]];
    fetchRequest.fetchLimit = 1;
    NSExpression *selectedExpression = [NSExpression expressionForKeyPath:PLCMapAttributes.selected];
    NSExpression *yesExpression = [NSExpression expressionForConstantValue:@YES];
    fetchRequest.predicate = [NSComparisonPredicate predicateWithLeftExpression:selectedExpression
                                                                rightExpression:yesExpression
                                                                       modifier:0
                                                                           type:NSEqualToPredicateOperatorType
                                                                        options:0];
    return [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] firstObject];
}

- (void)setSelectedMap:(PLCMap *)selectedMap {
    if (selectedMap == [self selectedMap]) {
        return;
    }
    for (PLCMap *map in [self allMaps]) {
        map.selectedValue = NO;
    }
    selectedMap.selectedValue = YES;
    [[self managedObjectContext] save:nil];
    [self.delegate mapStore:self didChangeMap:selectedMap];
    [[NSNotificationCenter defaultCenter] postNotificationName:PLCCurrentMapDidChangeNotification object:self];
}

- (PLCMap *)insertMapWithName:(NSString *)name {
    PLCMap *map = [PLCMap insertInManagedObjectContext:[self managedObjectContext]];
    [self updateMap:map withName:name];
    return map;
}

- (void)updateMap:(PLCMap *)map withName:(NSString *)name {
    map.name = name;
    [[self managedObjectContext] save:nil];
    [[[Firebase mapClient] childByAppendingPath:map.uuid] setValue:[map firebaseObject] andPriority:[[PLCUserStore sharedInstance] currentUserId]];
}

- (void)deleteMapAtIndex:(NSUInteger)index {
    NSArray *maps = self.notDeletedMaps;
    PLCMap *map = [maps objectAtIndex:index];
    if (!map) {
        return;
    }
    map.deletedAt = [NSDate date];
    [[[Firebase mapClient] childByAppendingPath:map.uuid] setValue:[map firebaseObject] andPriority:[[PLCUserStore sharedInstance] currentUserId]];
    PLCMap *newMap;
    BOOL didChangeSelection = map.selectedValue;
    if (map.selectedValue) {
        map.selectedValue = NO;
        NSUInteger newIndex = (index == 0) ? 1 : index - 1;
        newMap = [maps objectAtIndex:newIndex];
        newMap.selectedValue = YES;
    }
    [[self managedObjectContext] save:nil];
    if (didChangeSelection) {
        [self.delegate mapStore:self didChangeMap:newMap];
        [[NSNotificationCenter defaultCenter] postNotificationName:PLCCurrentMapDidChangeNotification object:self];
    }
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath {
    for (id<NSFetchedResultsControllerDelegate> delegate in self.delegates) {
        [delegate controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    }
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
             atIndex:(NSUInteger)sectionIndex
       forChangeType:(NSFetchedResultsChangeType)type {
    for (id<NSFetchedResultsControllerDelegate> delegate in self.delegates) {
        [delegate controller:controller didChangeSection:sectionInfo atIndex:sectionIndex forChangeType:type];
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    for (id<NSFetchedResultsControllerDelegate> delegate in self.delegates) {
        [delegate controllerWillChangeContent:controller];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    for (id<NSFetchedResultsControllerDelegate> delegate in self.delegates) {
        [delegate controllerDidChangeContent:controller];
    }
}

- (void)registerDelegate:(id<NSFetchedResultsControllerDelegate>)delegate {
    [self.delegates addObject:delegate];
}

- (void)unregisterDelegate:(id<NSFetchedResultsControllerDelegate>)delegate {
    [self.delegates removeObject:delegate];
}

- (void)save {
    [[self managedObjectContext] save:nil];
    [self.delegate mapStore:self didChangeMap:self.selectedMap];
}

- (void)downloadMapsForUserId:(NSString *)userId {
    [[[Firebase mapClient] queryStartingAtValue:userId]
        observeSingleEventOfType:FEventTypeValue
                       withBlock:^(FDataSnapshot *snapshot) {
                           id maps = [snapshot value];
                           if (maps == [NSNull null]) {
                               return;
                           }
                           [maps enumerateKeysAndObjectsUsingBlock:^(NSString *mapId, NSDictionary *mapDict, BOOL *stop) {
                               if ([mapDict[@"PLCDeletedAt"] doubleValue] > 1000.0f) {
                                   return;
                               }
                               id places = mapDict[@"places"];
                               if (!places || places == [NSNull null]) {
                                   return;
                               }
                               PLCMap *map = [self mapWithUUID:mapId];
                               if (!map) {
                                   map = [PLCMap insertInManagedObjectContext:[self managedObjectContext]];
                                   map.name = mapDict[@"name"];
                                   map.uuid = mapId;
                               }
                               [mapDict[@"places"] enumerateKeysAndObjectsUsingBlock:^(NSString *placeId, NSDictionary *placeDict, BOOL *stop) {
                                   if (![[[[PLCPlaceStore sharedInstance] allPlaces] valueForKeyPath:@"uuid"] containsObject:placeId]) {
                                       CLLocationCoordinate2D coord =
                                           CLLocationCoordinate2DMake([placeDict[@"latitude"] doubleValue], [placeDict[@"longitude"] doubleValue]);
                                       if (!CLLocationCoordinate2DIsValid(coord)) {
                                           [[[[[Firebase mapClient] childByAppendingPath:mapId] childByAppendingPath:@"places"]
                                               childByAppendingPath:placeId] removeValue];
                                           return;
                                       }
                                       PLCPlace *place = [PLCPlace insertInManagedObjectContext:[self managedObjectContext]];
                                       place.latitude = placeDict[@"latitude"];
                                       place.longitude = placeDict[@"longitude"];
                                       place.uuid = placeId;
                                       place.caption = placeDict[@"caption"];
                                       place.map = map;
                                       place.geocodedAddress = placeDict[@"geocodedAddress"];
                                       if (!place.geocodedAddress && !place.deletedAt && !map.deletedAt) {
                                           [place setCoordinate:coord]; // this triggers a geocode operation
                                       }
                                       if ([placeDict[@"PLCDeletedAt"] doubleValue] > 1000) {
                                           place.deletedAt = [NSDate dateWithTimeIntervalSinceReferenceDate:[placeDict[@"PLCDeletedAt"] doubleValue]];
                                       }
                                   }
                               }];
                           }];
                           [[self managedObjectContext] save:nil];
                       }];
}

@end
