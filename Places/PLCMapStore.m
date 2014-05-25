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

- (void)setSelectedMap:(PLCMap *)selectedMap {
    if (selectedMap == _selectedMap) {
        return;
    }
    _selectedMap = selectedMap;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *url = [_selectedMap.objectID URIRepresentation];
    [defaults setObject:url forKey:PLCCurrentMapSaveKey];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:PLCCurrentMapDidChangeNotification object:self];
}

- (PLCMap *)selectedMap {
    if (!_selectedMap) {
        if (!self.allMaps.count) {
            _selectedMap = [PLCMap insertInManagedObjectContext:[self managedObjectContext]];
            [[self managedObjectContext] save:nil];
            self.selectedMap = _selectedMap;
        }
        else {
            NSURL *objectURI = [[NSUserDefaults standardUserDefaults] URLForKey:PLCCurrentMapSaveKey];
            NSManagedObjectID *objectId = [[[self managedObjectContext] persistentStoreCoordinator] managedObjectIDForURIRepresentation:objectURI];
            _selectedMap = (PLCMap *)[[self managedObjectContext] existingObjectWithID:objectId error:nil];
        }
    }
    return _selectedMap;
}

@end
