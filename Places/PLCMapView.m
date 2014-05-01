//
//  PLCMapView.m
//  Places
//
//  Created by Jack Flintermann on 4/19/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCMapView.h"

@implementation PLCMapView

@dynamic delegate;

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // Note: `gestureRecognizer` could be an internal MKMapView gesture recognizer. We want to block all touches that
    // could conflict with callout view gesture handling.

    for (UIViewController *presentedViewController in [self.delegate presentedCalloutViewControllersForMapView:self]) {
        CGPoint point = [touch locationInView:presentedViewController.view];
        if ([presentedViewController.view pointInside:point withEvent:nil]) {
            return NO;
        }
    }
    return YES;
}

- (void) setRegion:(MKCoordinateRegion)region {
    if ([self regionIsValid:region]) {
        [super setRegion:region];
    }
}

- (BOOL)regionIsValid:(MKCoordinateRegion)region {
    return !(region.span.latitudeDelta <= 0.0f ||
             region.span.longitudeDelta <= 0.0f ||
             region.span.latitudeDelta >= 180.0f ||
             region.span.longitudeDelta >= 180.0f ||
             region.center.latitude > 90.0f ||
             region.center.latitude < -90.0f ||
             region.center.longitude > 360.0f ||
             region.center.longitude < -180.0f);
}

@end
