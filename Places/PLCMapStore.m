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

@implementation PLCMapStore

+ (NSArray *)allMaps {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[PLCMap entityName]];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:PLCMapAttributes.name ascending:YES]];
    NSExpression *nilExpression = [NSExpression expressionForConstantValue:[NSNull null]];
    NSExpression *deletedAtExpression = [NSExpression expressionForKeyPath:PLCMapAttributes.deletedAt];
    NSPredicate *notDeletedPredicate = [NSComparisonPredicate predicateWithLeftExpression:deletedAtExpression
                                                                          rightExpression:nilExpression
                                                                                 modifier:NSDirectPredicateModifier
                                                                                     type:NSEqualToPredicateOperatorType
                                                                                  options:0];
    fetchRequest.predicate = notDeletedPredicate;
    return [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] sortedArrayUsingComparator:^NSComparisonResult(PLCMap *obj1, PLCMap *obj2) {
        return [obj1.name caseInsensitiveCompare:obj2.name];
    }];
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

+ (NSManagedObjectContext *)managedObjectContext {
    return [PLCDatabase sharedDatabase].mainContext;
}

+ (void)createDefaultMapIfNecessary {
    if ([self allMaps].count == 0) {
        [self createMapWithName:NSLocalizedString(@"Places", nil)];
    }
}

@end
