//
//  PLCPlace.m
//  Places
//
//  Created by Cameron Spickert on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPlace.h"

@implementation PLCPlace

#pragma mark MKAnnotation

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
}

- (NSString *) title {
    return [self.caption copy];
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate NS_AVAILABLE(10_9, 4_0) {
    self.latitude = @(newCoordinate.latitude);
    self.longitude = @(newCoordinate.longitude);
}

// The MKAnnotation protocol dictates that the coordinate property be KVO-compliant.
+ (NSSet *) keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSMutableSet *set = [NSMutableSet setWithSet:[super keyPathsForValuesAffectingValueForKey:key]];
    if ([key isEqualToString:@"coordinate"]) {
        [set addObjectsFromArray:@[PLCPlaceAttributes.latitude, PLCPlaceAttributes.longitude]];
    }
    return [set copy];
}

@end
