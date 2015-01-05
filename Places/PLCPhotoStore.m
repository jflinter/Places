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
    [[TMCache sharedCache] setObject:image
                              forKey:uuid
                               block:^(__unused TMCache *cache, __unused NSString *key, __unused id object) {
                                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                       NSData *data = UIImageJPEGRepresentation(image, 1);
                                       PLCImageSavingWork *work = [[PLCImageSavingWork alloc] initWithImage:data imageId:uuid placeId:place.uuid];
                                       [[PLCPersistentQueue sharedInstance] addWork:work];
                                   });
                               }];
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
                                  block:^(__unused TMCache *cache, __unused NSString *key, id cacheObject) {
                                      if (cacheObject) {
                                          completion(cacheObject);
                                          return;
                                      }
                                      PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
                                      [query whereKey:@"imageId" equalTo:imageId];
                                      [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                          if (!objects || !objects.count || error) {
                                              completion(nil);
                                          } else {
                                              PFObject *object = objects.firstObject;
                                              PFFile *imageFile = object[@"imageFile"];
                                              [imageFile getDataInBackgroundWithBlock:^(NSData *data, __unused NSError *fetchError) {
                                                  if (data && !fetchError) {
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
