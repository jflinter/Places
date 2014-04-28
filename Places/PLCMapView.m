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

@end
