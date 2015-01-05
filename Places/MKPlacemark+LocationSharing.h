//
//  MKPlacemark+LocationSharing.h
//  Places
//
//  Created by Jack Flintermann on 5/9/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKPlacemark (LocationSharing)

extern NSString * const MKPlaceMarkPLCMapFieldNameKey;
extern NSString * const MKPlaceMarkPLCMapFieldValueKey;
extern NSString * const MKPlaceMarkPLCMapPreviewKey;

- (NSURL *)jrf_temporaryFileURLForLocationSharingWithOptions:(NSDictionary *)options error:(NSError**)error;

@end
