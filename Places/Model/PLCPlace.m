//
//  PLCPlace.m
//  Places
//
//  Created by Cameron Spickert on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPlace.h"
#import "MKPlacemark+LocationSharing.h"

@implementation PLCPlace

#pragma mark -
#pragma mark Geocoding

- (void) geocode {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark *placemark = [placemarks firstObject];
            self.geocodedAddress = [placemark.addressDictionary mutableCopy];
            [self.managedObjectContext save:nil];
        }
    }];
}

#pragma mark MKAnnotation

- (UIImage *)image {
    return [[self.photos anyObject] image];
}

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
}

- (NSString *) title {
    return [self.caption copy];
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    self.latitude = @(newCoordinate.latitude);
    self.longitude = @(newCoordinate.longitude);
    [self geocode];
}

// The MKAnnotation protocol dictates that the coordinate property be KVO-compliant.
+ (NSSet *) keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSMutableSet *set = [NSMutableSet setWithSet:[super keyPathsForValuesAffectingValueForKey:key]];
    if ([key isEqualToString:@"coordinate"]) {
        [set addObjectsFromArray:@[PLCPlaceAttributes.latitude, PLCPlaceAttributes.longitude]];
    }
    return [set copy];
}

#pragma mark -
#pragma mark UIActivityItemSource

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return self.caption;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController
                  itemForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:UIActivityTypeMessage]) {
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:self.geocodedAddress];
        NSURL *url = [placemark temporaryFileURLForLocationSharing:nil];
        if (url) {
            return url;
        }
        else {
            return self.caption;
        }
    }
    if ([activityType isEqualToString:UIActivityTypeSaveToCameraRoll]) {
        return self.image;
    }
    else {
        return self.caption;
    }
}

@end
