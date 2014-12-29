//
//  PLCImageSavingWork.m
//  Places
//
//  Created by Jack Flintermann on 12/29/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCImageSavingWork.h"
#import <Parse/Parse.h>
#import "PLCDatabase.h"
#import "PLCPlace.h"
#import "Firebase+Places.h"

@interface PLCImageSavingWork ()
@property (nonatomic) NSData *imageData;
@property (nonatomic) NSString *imageId;
@property (nonatomic) NSString *placeId;
@end

@implementation PLCImageSavingWork

+ (NSUInteger)modelVersion {
    return 0;
}

- (instancetype)initWithImage:(NSData *)imageData imageId:(NSString *)imageId placeId:(NSString *)placeId {
    self = [super init];
    if (self) {
        _imageData = imageData;
        _imageId = imageId;
        _placeId = placeId;
    }
    return self;
}

- (void)doWork:(PLCAsynchronousWorkCallback)completion {
    PFFile *file = [PFFile fileWithName:self.imageId data:self.imageData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            completion(error);
        } else {
            PFObject *photoObject = [PFObject objectWithClassName:@"Photo" dictionary:@{ @"imageId": self.imageId, @"imageFile": file }];
            [photoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    completion(error);
                } else {
                    PLCPlace *place = [self.class placeWithUUID:self.placeId];
                    [place.managedObjectContext performBlock:^{
                        place.imageIds = @[self.imageId];
                        [place.managedObjectContext save:nil];
                        [[Firebase placeClientForPlace:place] setValue:[place firebaseObject]];
                        completion(nil);
                    }];
                }
            }];
        }
    }];
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
