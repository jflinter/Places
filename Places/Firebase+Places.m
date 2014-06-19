//
//  Firebase+Places.m
//  Places
//
//  Created by Jack Flintermann on 5/30/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "Firebase+Places.h"
#import "PLCUserStore.h"
#import "PLCMap.h"
#import "PLCPlace.h"
#import "PLCPhoto.h"

@implementation Firebase (Places)

+ (instancetype)placesFirebaseClient {
    return [[self alloc] initWithUrl:@"https://shareplaces.firebaseio.com/"];
}

+ (instancetype)mapClient {
    return [[self placesFirebaseClient] childByAppendingPath:@"maps"];
}

+ (instancetype)mapClientForMap:(PLCMap *)map {
    return [[self mapClient] childByAppendingPath:map.uuid];
}

+ (instancetype)placeClientForPlace:(PLCPlace *)place {
    return [[[self mapClientForMap:place.map] childByAppendingPath:@"places"] childByAppendingPath:place.uuid];
}

+ (instancetype)photoClientForPhoto:(PLCPhoto *)photo {
    return [[[self placeClientForPlace:photo.place] childByAppendingPath:@"photos"] childByAppendingPath:photo.uuid];
}

@end
