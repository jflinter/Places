//
//  PLCPlaceCalloutViewModel.m
//  Places
//
//  Created by Jack Flintermann on 3/17/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import "PLCPlaceCalloutViewModel.h"
#import "PLCPlaceStore.h"
#import "PLCPlace.h"
#import "PLCGoogleMapsActivity.h"

@interface PLCPlaceCalloutViewModel()
@property(nonatomic)PLCSelectedMapViewModel *parentViewModel;
@property(nonatomic)PLCPlace *place;
@end

@implementation PLCPlaceCalloutViewModel

- (instancetype)initWithParentViewModel:(PLCSelectedMapViewModel *)parentViewModel place:(PLCPlace *)place {
    self = [super init];
    if (self) {
        _parentViewModel = parentViewModel;
        _place = place;
    }
    return self;
}

- (void)removePlace {
    [self.parentViewModel removePlace:self.place];
}

- (void)renamePlaceWithTitle:(NSString *)title {
    [PLCPlaceStore updatePlace:self.place withCaption:title];
}

- (UIActivityViewController *)activityViewControllerForSharingPlace {
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.place.coordinate addressDictionary:self.place.geocodedAddress];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[self.place, mapItem] applicationActivities:@[[PLCGoogleMapsActivity new]]];
    // exclude the airdrop action because it's incredibly fucking slow and noone uses it
    NSMutableArray *excludedTypes = [@[UIActivityTypePrint, UIActivityTypeAirDrop] mutableCopy];
    if (!self.place.geocodedAddress) {
        [excludedTypes addObject:UIActivityTypeMessage];
    }
    //    if (!self.place.image) {
    [excludedTypes addObject:UIActivityTypeAssignToContact];
    //    }
    activityViewController.excludedActivityTypes = [excludedTypes copy];
    return activityViewController;
}

- (BOOL)hasCaption {
    return self.place.caption && ![self.place.caption isEqualToString:@""];
}

@end
