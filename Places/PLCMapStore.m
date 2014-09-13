//
//  PLCMapStore.m
//  Places
//
//  Created by Jack Flintermann on 5/22/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCMapStore.h"
#import "PLCDatabase.h"
#import "PLCMap.h"
#import "PLCUserStore.h"
#import <Firebase/Firebase.h>
#import "Firebase+Places.h"

static NSString * const PLCCurrentMapSaveKey = @"PLCCurrentMapSaveKey";
static NSString * const PLCCurrentMapDidChangeNotification = @"PLCCurrentMapDidChangeNotification";

@interface PLCMapStore()<NSFetchedResultsControllerDelegate>
@property(nonatomic)NSFetchedResultsController *fetchedResultsController;
@property(nonatomic)NSMutableArray *delegates;
- (NSArray *)allMaps;
@end

@implementation PLCMapStore

+ (instancetype)sharedInstance {
    static PLCMapStore *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _delegates = [@[] mutableCopy];
        self.selectedMap = [self selectedMap] ?: [self defaultMap];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequest:NO] managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
        self.fetchedResultsController.delegate = self;
        [self.fetchedResultsController performFetch:nil];
    }
    return self;
}

- (NSUInteger)numberOfMaps {
    id<NSFetchedResultsSectionInfo> section = [[self.fetchedResultsController sections] firstObject];
    return [section numberOfObjects];
}

- (NSArray *) notDeletedMaps {
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
    NSPredicate *notDeletedPredicate = [NSComparisonPredicate predicateWithLeftExpression:deletedAtExpression rightExpression:nilExpression modifier:NSDirectPredicateModifier type:NSEqualToPredicateOperatorType options:0];
    if (!allowDeleted) {
        fetchRequest.predicate = notDeletedPredicate;
    }
    return fetchRequest;
}

- (NSManagedObjectContext *)managedObjectContext {
    return [PLCDatabase sharedDatabase].mainContext;
}

- (PLCMap *)mapAtIndex:(NSUInteger)index {
    return [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:(NSInteger)index inSection:0]];
}

- (PLCMap *)defaultMap {
    return [self insertMapWithName:NSLocalizedString(@"My Neighborhood", nil)];
}

- (PLCMap *)selectedMap {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[PLCMap entityName]];
    fetchRequest.fetchLimit = 1;
    NSExpression *selectedExpression = [NSExpression expressionForKeyPath:PLCMapAttributes.selected];
    NSExpression *yesExpression = [NSExpression expressionForConstantValue:@YES];
    fetchRequest.predicate = [NSComparisonPredicate predicateWithLeftExpression:selectedExpression rightExpression:yesExpression modifier:0 type:NSEqualToPredicateOperatorType options:0];
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
    map.name = name;
    [[self managedObjectContext] save:nil];
    [[[Firebase mapClient] childByAppendingPath:map.uuid] setValue:[map firebaseObject] andPriority:[[PLCUserStore sharedInstance] currentUserId]];
    return map;
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

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    for (id<NSFetchedResultsControllerDelegate> delegate in self.delegates) {
        [delegate controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
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

@end
