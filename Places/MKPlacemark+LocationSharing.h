//
//  MKPlacemark+LocationSharing.h
//  Places
//
//  Created by Jack Flintermann on 5/9/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKPlacemark (LocationSharing)

- (NSURL *)temporaryFileURLForLocationSharing:(NSError**)error;

@end
