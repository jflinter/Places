//
//  Firebase+Places.h
//  Places
//
//  Created by Jack Flintermann on 5/30/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Firebase/Firebase.h>

@class PLCMap, PLCPlace, PLCPhoto;

@interface Firebase (Places)

+ (instancetype)placesFirebaseClient;
+ (instancetype)mapClient;
+ (instancetype)mapClientForMap:(PLCMap *)map;
+ (instancetype)placeClientForPlace:(PLCPlace *)place;
+ (instancetype)currentUserClient;

@end
