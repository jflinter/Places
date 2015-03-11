//
//  PLCDataImporter.m
//  Places
//
//  Created by Jack Flintermann on 3/10/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import "PLCDataImporter.h"

@implementation PLCDataImporter


+ (void)downloadMapsForUserId:(__unused NSString *)userId {
    //    FQuery *query;
    //    if (userId) {
    //        query = [[[Firebase mapClient] queryStartingAtValue:userId] queryEndingAtValue:userId];
    //    } else {
    //        query = [[Firebase mapClient] queryOrderedByPriority];
    //    }
    //    [query observeSingleEventOfType:FEventTypeValue
    //                          withBlock:^(FDataSnapshot *snapshot) {
    //                            NSDictionary *maps = [snapshot value];
    //                            if (![maps isKindOfClass:[NSDictionary class]]) {
    //                                return;
    //                            }
    //                            [maps enumerateKeysAndObjectsUsingBlock:^(NSString *mapId, NSDictionary *mapDict, __unused BOOL *mapstop) {
    //                              if ([mapDict[@"PLCDeletedAt"] doubleValue] > 1000.0f) {
    //                                  return;
    //                              }
    //                              id places = mapDict[@"places"];
    //                              if (!places || places == [NSNull null]) {
    //                                  return;
    //                              }
    //                              PLCMap *map = [self mapWithUUID:mapId];
    //                              if (!map) {
    //                                  map = [PLCMap insertInManagedObjectContext:[self managedObjectContext]];
    //                                  map.name = mapDict[@"name"];
    //                                  map.uuid = mapId;
    //                                  map.urlId = mapDict[@"urlId"];
    //                                  if (!map.urlId) {
    //                                      map.urlId = [self urlIdForMap:map];
    //                                      [[[[Firebase placesFirebaseClient] childByAppendingPath:@"urls"] childByAppendingPath:map.urlId] setValue:map.uuid];
    //                                  }
    //                              }
    //                              [mapDict[@"places"] enumerateKeysAndObjectsUsingBlock:^(NSString *placeId, NSDictionary *placeDict, __unused BOOL *placestop) {
    //                                CLLocationCoordinate2D coord =
    //                                    CLLocationCoordinate2DMake([placeDict[@"latitude"] doubleValue], [placeDict[@"longitude"] doubleValue]);
    //                                if (!CLLocationCoordinate2DIsValid(coord)) {
    //                                    [[[[[Firebase mapClient] childByAppendingPath:mapId] childByAppendingPath:@"places"]
    //                                        childByAppendingPath:placeId] removeValue];
    //                                    return;
    //                                }
    //                                PLCPlace *place = [PLCPlace insertInManagedObjectContext:[self managedObjectContext]];
    //                                place.latitude = placeDict[@"latitude"];
    //                                place.longitude = placeDict[@"longitude"];
    //                                place.uuid = placeId;
    //                                place.caption = placeDict[@"caption"];
    //                                place.map = map;
    //                                place.imageIds = placeDict[@"imageIds"];
    //                                place.geocodedAddress = placeDict[@"geocodedAddress"];
    //                                if (!place.geocodedAddress && !place.deletedAt && !map.deletedAt) {
    //                                    [place setCoordinate:coord]; // this triggers a geocode operation
    //                                }
    //                                if ([placeDict[@"PLCDeletedAt"] doubleValue] > 1000) {
    //                                    place.deletedAt = [NSDate dateWithTimeIntervalSinceReferenceDate:[placeDict[@"PLCDeletedAt"] doubleValue]];
    //                                }
    //                              }];
    //                            }];
    //                            [[self managedObjectContext] save:nil];
    //                          }];
}

@end
