//
//  PLCGeocodingWork.m
//  Places
//
//  Created by Jack Flintermann on 12/28/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCGeocodingWork.h"
#import "PLCPlace.h"
#import "PLCDatabase.h"

@interface PLCGeocodingWork ()
@property (nonatomic) CLLocation *location;
@property (nonatomic) NSString *placeId;
@end

@implementation PLCGeocodingWork

+ (NSUInteger)modelVersion {
    return 0;
}

- (void)doWork:(PLCAsynchronousWorkCallback)completion {
    [[CLGeocoder new] reverseGeocodeLocation:self.location
                           completionHandler:^(NSArray *placemarks, NSError *error) {
                               PLCPlace *place = [self.class placeWithUUID:self.placeId];
                               MKPlacemark *placemark = [placemarks firstObject];
                               [[self.class managedObjectContext] performBlock:^{
                                   place.geocodedAddress = [[placemark addressDictionary] mutableCopy];
                                   [[self.class managedObjectContext] save:nil];
                               }];
                               completion(error);
                           }];
}

- (instancetype)initWithLocation:(CLLocation *)location placeId:(NSString *)placeId {
    self = [super init];
    if (self) {
        _location = location;
        _placeId = placeId;
    }
    return self;
}

+ (PLCPlace *)placeWithUUID:(NSString *)uuid {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[PLCPlace entityName]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uuid == %@", uuid];

    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    return [fetchedObjects firstObject];
}

+ (NSManagedObjectContext *)managedObjectContext {
    return [PLCDatabase sharedDatabase].mainContext;
}

@end
