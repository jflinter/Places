//
//  PLCPhotoStore.m
//  Places
//
//  Created by Jack Flintermann on 4/27/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPhotoStore.h"
#import "PLCPlace.h"
#import <Firebase/Firebase.h>
#import "Firebase+Places.h"
#import <Parse/Parse.h>
#import "PLCImageSavingWork.h"
#import <TMCache/TMCache.h>

@implementation PLCPhotoStore

- (void)addPhotoWithImage:(UIImage *)image toPlace:(PLCPlace *)place withUUID:(NSString *)uuid {
    // places store an array of parse uuids
    // to add a photo:
    // delete any existing photos
    [self removePhotoFromPlace:place];
    place.image = image;
    [[TMCache sharedCache] setObject:image forKey:uuid];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // save the file locally with that uuid
        NSData *data = UIImageJPEGRepresentation(image, 1);
        [data writeToFile:[self fileUrlForPhotoWithUUID:uuid].path atomically:YES];
        PLCImageSavingWork *work = [[PLCImageSavingWork alloc] initWithImage:data imageId:uuid placeId:place.uuid];
        [[PLCPersistentQueue sharedInstance] addWork:work];
    });
}

- (NSURL *)fileUrlForPhotoWithUUID:(NSString *)uuid {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    return [[[documentsURL URLByAppendingPathComponent:@"PLCPhotoStore"] URLByAppendingPathComponent:uuid] URLByAppendingPathExtension:@"jpg"];
}

- (void)removePhotoFromPlace:(PLCPlace *)place {
    // delete files from parse
    [place.managedObjectContext performBlock:^{
        place.imageIds = @[];
        [place.managedObjectContext save:nil];
        [[Firebase placeClientForPlace:place] setValue:[place firebaseObject]];
    }];
}

- (void)fetchImageWithId:(NSString *)imageId completion:(PLCImageFetchBlock)completion {
    [[TMCache sharedCache] objectForKey:imageId
                                  block:^(TMCache *cache, NSString *key, id object) {
                                      if (object) {
                                          completion(object);
                                          return;
                                      }
                                      PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
                                      [query whereKey:@"imageId" equalTo:imageId];
                                      [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                          if (!objects || !objects.count || error) {
                                              completion(nil);
                                          } else {
                                              PFObject *object = objects.firstObject;
                                              PFFile *imageFile = [object objectForKey:@"imageFile"];
                                              [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                                  if (data) {
                                                      UIImage *image = [[UIImage alloc] initWithData:data];
                                                      [[TMCache sharedCache] setObject:image forKey:imageId];
                                                      completion(image);
                                                  } else {
                                                      completion(nil);
                                                  }
                                              }];
                                          }
                                      }];
                                  }];
}

@end
