//
//  PLCPhotoStore.m
//  Places
//
//  Created by Jack Flintermann on 4/27/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPhotoStore.h"
#import "PLCPhoto.h"
#import "PLCPlace.h"
#import <Firebase/Firebase.h>
#import "Firebase+Places.h"

@implementation PLCPhotoStore

- (void) addPhotoWithImage:(UIImage *)image
                   toPlace:(PLCPlace *)place {
    for (PLCPhoto *photo in place.photos) {
        [place.managedObjectContext deleteObject:photo];
        [[Firebase photoClientForPhoto:photo] removeValue];
    }
    if (image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData *data = UIImageJPEGRepresentation(image, 1);
            [place.managedObjectContext performBlock:^{
                PLCPhoto *photo = [PLCPhoto insertInManagedObjectContext:place.managedObjectContext];
                photo.imageData = data;
                photo.place = place;
                [place.managedObjectContext save:nil];
                [[Firebase photoClientForPhoto:photo] setValue:[photo firebaseObject]];
            }];
        });
    }
}

@end
