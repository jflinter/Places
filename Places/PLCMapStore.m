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
#import "PLCPhotoStore.h"
#import <TMCache/TMCache.h>

static NSString *const PLCCurrentMapSaveKey = @"PLCCurrentMapSaveKey";
static NSString *const PLCCurrentMapDidChangeNotification = @"PLCCurrentMapDidChangeNotification";

@interface PLCMapStore () <NSFetchedResultsControllerDelegate>
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSMutableArray *delegates;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *allMaps;
@property (nonatomic) PLCPlaceStore *placeStore;
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

- (instancetype)init {
    self = [super init];
    if (self) {
        _delegates = [@[] mutableCopy];
        self.selectedMap = [self selectedMap] ?: [self.class defaultMap];
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequest:NO]
                                                                        managedObjectContext:[self.class managedObjectContext]
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
        _fetchedResultsController.delegate = self;
        [_fetchedResultsController performFetch:nil];
    }
    return self;
}

- (void)dealloc {
    _fetchedResultsController.delegate = nil;
}

- (NSUInteger)numberOfMaps {
    id<NSFetchedResultsSectionInfo> section = [[self.fetchedResultsController sections] firstObject];
    return [section numberOfObjects];
}

- (NSArray *)notDeletedMaps {
    return self.fetchedResultsController.fetchedObjects;
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

+ (PLCMap *)mapWithUUID:(NSString *)uuid {
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

+ (NSManagedObjectContext *)managedObjectContext {
    return [PLCDatabase sharedDatabase].mainContext;
}

- (PLCMap *)mapAtIndex:(NSUInteger)index {
    return [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:(NSInteger)index inSection:0]];
}

+ (PLCMap *)defaultMap {
    return [self createMapWithName:NSLocalizedString(@"Places", nil)];
}

+ (PLCMap *)createMapWithName:(NSString *)name {
    PLCMap *map = [PLCMap insertInManagedObjectContext:[self managedObjectContext]];
    [self updateMap:map withName:name];
    return map;
}

+ (void)updateMap:(PLCMap *)map withName:(NSString *)name {
    map.name = name;
    NSString *slug = [self slugForMap:map];
    map.urlId = slug;
    [[self managedObjectContext] save:nil];
    [[[Firebase mapClient] childByAppendingPath:map.uuid] setValue:[map firebaseObject] andPriority:[[PLCUserStore sharedInstance] currentUserId]];
    [[[[Firebase placesFirebaseClient] childByAppendingPath:@"urls"] childByAppendingPath:slug] setValue:map.uuid];
}

+ (void)deleteMap:(PLCMap *)map {
    map.deletedAt = [NSDate date];
    [[self managedObjectContext] save:nil];
}

- (void)deleteMapAtIndex:(__unused NSUInteger)index {
//    NSArray *maps = self.notDeletedMaps;
//    PLCMap *map = maps[index];
//    if (!map) {
//        return;
//    }
//    map.deletedAt = [NSDate date];
//    [[[Firebase mapClient] childByAppendingPath:map.uuid] setValue:[map firebaseObject] andPriority:[[PLCUserStore sharedInstance] currentUserId]];
//    PLCMap *newMap;
//    if (map.selectedValue) {
//        map.selectedValue = NO;
//        NSUInteger newIndex = (index == 0) ? 1 : index - 1;
//        newMap = maps[newIndex];
//        newMap.selectedValue = YES;
//        self.selectedMap = newMap;
//    }
//    [[self managedObjectContext] save:nil];
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

+ (NSString *)slugForMap:(PLCMap *)map {
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *mapId = [@"" mutableCopy];
    for (NSInteger i = 0; i < 8; i++) {
        NSUInteger idx = (NSUInteger)arc4random_uniform((u_int32_t)letters.length);
        NSString *letter = [letters substringWithRange:NSMakeRange(idx, 1)];
        [mapId appendString:letter];
    }
    NSString *urlId = @"";
    if (map.name) {
        NSCharacterSet *set = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        urlId = [[[map.name componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@"-"] stringByAppendingString:@"-"];
    }
    urlId = [urlId stringByAppendingString:mapId];
    NSParameterAssert(urlId);
    return urlId;
}

@end
