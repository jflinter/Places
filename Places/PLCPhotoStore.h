//
//  PLCPhotoStore.h
//  Places
//
//  Created by Jack Flintermann on 4/27/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLCPhoto, PLCPlace;

typedef void (^PLCImageFetchBlock)(UIImage *image);

@interface PLCPhotoStore : NSObject

- (void)addPhotoWithImage:(UIImage *)image toPlace:(PLCPlace *)place withUUID:(NSString *)uuid;
- (void)removePhotoFromPlace:(PLCPlace *)place;
- (void)fetchImageWithId:(NSString *)imageId completion:(PLCImageFetchBlock)completion;

@end
