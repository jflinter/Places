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
#import "PLCGeocodingWork.h"

@implementation PLCPlace

@synthesize image;

- (NSString *)imageId {
    return self.imageIds.firstObject;
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    if (!self.uuid) {
        self.uuid = [[NSUUID UUID] UUIDString];
    }
}

#pragma mark MKAnnotation

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
}

- (NSString *)title {
    return [[self.caption componentsSeparatedByString:@"\n"] firstObject];
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    self.latitude = @(newCoordinate.latitude);
    self.longitude = @(newCoordinate.longitude);
    CLLocation *location = [[CLLocation alloc] initWithLatitude:newCoordinate.latitude longitude:newCoordinate.longitude];
    PLCGeocodingWork *work = [[PLCGeocodingWork alloc] initWithLocation:location placeId:self.uuid];
    [[PLCPersistentQueue sharedInstance] addWork:work];
}

// The MKAnnotation protocol dictates that the coordinate property be KVO-compliant.
+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
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

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:UIActivityTypeMessage]) {
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:self.geocodedAddress];
        NSMutableDictionary *options = [@{
            MKPlaceMarkPLCMapFieldNameKey: @"Made with Places - see the rest here:",
            MKPlaceMarkPLCMapFieldValueKey: [self.map shareURL],
        } mutableCopy];
        if (self.caption && ![self.caption isEqualToString:@""]) {
            options[MKPlaceMarkPLCMapPreviewKey] = self.caption;
        }
        NSURL *url = [placemark temporaryFileURLForLocationSharingWithOptions:options error:nil];
        if (url) {
            return url;
        } else {
            return self.caption;
        }
    }
    if ([activityType isEqualToString:UIActivityTypeSaveToCameraRoll]) {
        return self.image;
    }
    if ([activityType isEqualToString:PLCGoogleMapsActivityType]) {
        return [[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:self.geocodedAddress];
    } else {
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
