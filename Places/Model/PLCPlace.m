//
//  PLCPlace.m
//  Places
//
//  Created by Cameron Spickert on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPlace.h"
#import "MKPlacemark+LocationSharing.h"
#import "NSMutableDictionary+NilSafe.h"
#import "PLCMap.h"
#import "PLCGoogleMapsActivity.h"
#import "PLCPlaceGeocoder.h"

@implementation PLCPlace

- (void)awakeFromInsert {
    [super awakeFromInsert];
    if (!self.uuid) {
        self.uuid = [[NSUUID UUID] UUIDString];
    }
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
    [[PLCPlaceGeocoder sharedInstance] reverseGeocodePlace:self];
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
        NSString *caption;
        if (self.caption && ![self.caption isEqualToString:@""]) {
            caption = self.caption;
        }
        NSDictionary *options = @{
                                  MKPlaceMarkPLCMapFieldNameKey: @"Made with Places - see the rest here:",
                                  MKPlaceMarkPLCMapFieldValueKey: [self.map shareURL],
                                  MKPlaceMarkPLCMapPreviewKey: caption,
                                  };
        NSURL *url = [placemark temporaryFileURLForLocationSharingWithOptions:options error:nil];
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
    if ([activityType isEqualToString:PLCGoogleMapsActivityType]) {
        return [[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:self.geocodedAddress];
    }
    else {
        return self.caption;
    }
}

- (PLCPlaceType)type {
    return (PLCPlaceType)self.placeType.unsignedIntegerValue;
}

#pragma mark - PLCFirebaseCoding

- (NSDictionary *)firebaseObject {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValueNilSafe:self.caption forKey:PLCPlaceAttributes.caption];
    [dictionary setValueNilSafe:self.latitude forKey:PLCPlaceAttributes.latitude];
    [dictionary setValueNilSafe:self.longitude forKey:PLCPlaceAttributes.longitude];
    [dictionary setValueNilSafe:self.geocodedAddress forKey:PLCPlaceAttributes.geocodedAddress];
    [dictionary setValueNilSafe:@(self.deletedAt.timeIntervalSinceReferenceDate) forKey:@"PLCDeletedAt"];
    return [dictionary copy];
}

@end
