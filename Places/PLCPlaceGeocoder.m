//
//  PLCPlaceGeocoder.m
//  Places
//
//  Created by Jack Flintermann on 7/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPlaceGeocoder.h"
#import "PLCGeocodingService.h"
#import "PLCGeocodingOperation.h"
#import "PLCPlace.h"
#import "PLCDatabase.h"


@interface PLCPlaceGeocoder()
@property(nonatomic)NSMutableDictionary *operations;
@end

@implementation PLCPlaceGeocoder

+(instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _operations = [@{} mutableCopy];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)reverseGeocodePlace:(PLCPlace *)place {
    [self reverseGeocodePlaceWithUUID:place.uuid];
}

- (void)reverseGeocodePlaceWithUUID:(NSString *)uuid {
    [self cancelOperationForUUID:uuid];
    PLCPlace *place = [self placeWithUUID:uuid];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:place.latitudeValue longitude:place.longitudeValue];
    if (!CLLocationCoordinate2DIsValid(location.coordinate)) {
        return;
    }
    NSOperation *operation = [[PLCGeocodingService sharedInstance] reverseGeocodeLocation:location completion:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            PLCPlace *place = [self placeWithUUID:uuid];
            MKPlacemark *placemark = [placemarks firstObject];
            [[self managedObjectContext] performBlock:^{
                place.geocodedAddress = [[placemark addressDictionary] mutableCopy];
                [[self managedObjectContext] save:nil];
            }];
        }
        [self operationFinishedForUUID:uuid];
    }];
    [self enqueueOperation:operation forUUID:uuid];
}

- (PLCPlace *)placeWithUUID:(NSString *)uuid {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[PLCPlace entityName]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uuid == %@", uuid];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    return [fetchedObjects firstObject];
}

- (NSManagedObjectContext *)managedObjectContext {
    return [PLCDatabase sharedDatabase].mainContext;
}

- (void)didEnterBackground:(NSNotification *)notification {
    [self.operations enumerateKeysAndObjectsUsingBlock:^(NSString *uuid, NSOperation *operation, BOOL *stop) {
        [operation cancel];
    }];
}

- (void)willEnterForeground:(NSNotification *)notification {
    [self resumeGeocoding];
}

- (void)resumeGeocoding {
    NSArray *uuids = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePath]];
    for (NSString *uuid in uuids) {
        [self reverseGeocodePlaceWithUUID:uuid];
    }
}

- (void)cancelOperationForUUID:(NSString *)uuid {
    [self.operations[uuid] cancel];
    [self operationFinishedForUUID:uuid];
}

- (void)enqueueOperation:(NSOperation *)operation forUUID:(NSString *)uuid {
    self.operations[uuid] = operation;
    [NSKeyedArchiver archiveRootObject:[self.operations allKeys] toFile:[self filePath]];
}

- (void)operationFinishedForUUID:(NSString *)uuid {
    [self.operations removeObjectForKey:uuid];
    [NSKeyedArchiver archiveRootObject:[self.operations allKeys] toFile:[self filePath]];
}

- (NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *operationsURL = [documentsURL URLByAppendingPathComponent:@"PLCPlaceGeocoderQueue"];
    return [operationsURL path];
}

@end
