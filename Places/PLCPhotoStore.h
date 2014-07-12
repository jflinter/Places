//
//  PLCPhotoStore.h
//  Places
//
//  Created by Jack Flintermann on 4/27/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLCPhoto, PLCPlace;

@interface PLCPhotoStore : NSObject

- (void) addPhotoWithImage:(UIImage *)image
                   toPlace:(PLCPlace *)place;
- (void) removePhotoFromPlace:(PLCPlace *)place;

@end
