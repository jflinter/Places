//
//  PLCGoogleMapsActivity.m
//  Places
//
//  Created by Jack Flintermann on 7/15/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCGoogleMapsActivity.h"

NSString * const PLCGoogleMapsActivityType = @"com.places.activity.googlemaps";

@interface PLCGoogleMapsActivity()

@property(nonatomic)MKMapItem *mapItem;

@end

@implementation PLCGoogleMapsActivity

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
}

- (NSString *)activityType {
    return PLCGoogleMapsActivityType;
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Directions", nil);
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"781-ships-wheel"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    for (id obj in activityItems) {
        if ([obj isKindOfClass:[MKMapItem class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    for (id obj in activityItems) {
        if ([obj isKindOfClass:[MKMapItem class]]) {
            self.mapItem = obj;
        }
    }
    
}

- (void)performActivity {
    NSString *callbackString = [NSString stringWithFormat:@"comgooglemaps-x-callback://?daddr=%f,%f&x-success=shareplaces://&x-source=Places", self.mapItem.placemark.coordinate.latitude, self.mapItem.placemark.coordinate.longitude];
    NSURL *callbackURL = [NSURL URLWithString:callbackString];
    NSString *urlString = [NSString stringWithFormat:@"comgooglemaps://?daddr=%f,%f", self.mapItem.placemark.coordinate.latitude, self.mapItem.placemark.coordinate.longitude];
    NSURL *googleUrl = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:callbackURL]) {
        [[UIApplication sharedApplication] openURL:callbackURL];
    }
    else if ([[UIApplication sharedApplication] canOpenURL:googleUrl]) {
        [[UIApplication sharedApplication] openURL:googleUrl];
    }
    else {
        [self.mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking}];
    }
    [self activityDidFinish:YES];
}

@end
