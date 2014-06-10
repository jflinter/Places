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
        PLCPhoto *photo = [PLCPhoto insertInManagedObjectContext:place.managedObjectContext];
        photo.image = image;
        photo.place = place;
        [[Firebase photoClientForPhoto:photo] setValue:[photo firebaseObject]];
        BOOL success = [place.managedObjectContext save:nil];
        if (!success) {
            abort();
        }

    }
}

@end
