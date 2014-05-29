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
        self.selectedMap = [self selectedMap] ?: [self defaultMap];
    }
    return self;
}

- (NSArray *)allMaps {
    return [[self managedObjectContext] executeFetchRequest:[self fetchRequest] error:nil];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:PLCCurrentMapDidChangeNotification object:self];
}

- (PLCMap *)insertMapWithName:(NSString *)name {
    PLCMap *map = [PLCMap insertInManagedObjectContext:[self managedObjectContext]];
    map.name = name;
    [[self managedObjectContext] save:nil];
    return map;
}

@end
