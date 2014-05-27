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

static NSString * const PLCCurrentMapSaveKey = @"PLCCurrentMapSaveKey";
static NSString * const PLCCurrentMapDidChangeNotification = @"PLCCurrentMapDidChangeNotification";

@interface PLCMapStore()<NSFetchedResultsControllerDelegate>
@property(nonatomic, readwrite, strong)NSFetchedResultsController *fetchedResultsController;
@end

@implementation PLCMapStore

@synthesize selectedMap = _selectedMap;

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
        self.selectedMap = [self savedSelectedMap] ?: [self defaultMap];
    }
    return self;
}

- (NSArray *)allMaps {
    return self.fetchedResultsController.fetchedObjects;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequest] managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
        [_fetchedResultsController performFetch:nil];
    }
    return _fetchedResultsController;
}

- (NSFetchRequest *)fetchRequest
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[PLCMap entityName]];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:PLCMapAttributes.name ascending:YES]];
    return fetchRequest;
}

- (NSManagedObjectContext *)managedObjectContext {
    return [PLCDatabase sharedDatabase].mainContext;
}

- (PLCMap *)mapAtIndex:(NSUInteger)index {
    return self.allMaps[index];
}

- (PLCMap *)savedSelectedMap {
    NSURL *objectURI = [[NSUserDefaults standardUserDefaults] URLForKey:PLCCurrentMapSaveKey];
    if (objectURI) {
        NSManagedObjectID *objectId = [[[self managedObjectContext] persistentStoreCoordinator] managedObjectIDForURIRepresentation:objectURI];
        NSError *error;
        return (PLCMap *)[[self managedObjectContext] existingObjectWithID:objectId error:&error];
    }
    return nil;
}

- (PLCMap *)defaultMap {
    return [self insertMapWithName:NSLocalizedString(@"Default Map", nil)];
}

- (void)setSelectedMap:(PLCMap *)selectedMap {
    _selectedMap = selectedMap;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *url = [_selectedMap.objectID URIRepresentation];
    [defaults setURL:url forKey:PLCCurrentMapSaveKey];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:PLCCurrentMapDidChangeNotification object:self];
}

- (PLCMap *)insertMapWithName:(NSString *)name {
    PLCMap *map = [PLCMap insertInManagedObjectContext:[self managedObjectContext]];
    map.name = name;
    [[self managedObjectContext] save:nil];
    return map;
}

@end
