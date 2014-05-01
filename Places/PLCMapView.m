//
//  PLCMapView.m
//  Places
//
//  Created by Jack Flintermann on 4/19/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCMapView.h"
#import <BDDROneFingerZoomGestureRecognizer/BDDROneFingerZoomGestureRecognizer.h>


@interface PLCMapViewInternalOneFingerGestureRecognizerDelegate : NSObject<UIGestureRecognizerDelegate>
@property(nonatomic, readwrite, weak)PLCMapView *mapView;
@end

@implementation PLCMapViewInternalOneFingerGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    return [self.mapView gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
}

@end


@interface PLCMapView()
@property(nonatomic) MKCoordinateRegion lastRegion;
@property(nonatomic) BDDROneFingerZoomGestureRecognizer *oneFingerZoomRecognizer;
@property(nonatomic) PLCMapViewInternalOneFingerGestureRecognizerDelegate *oneFingerGestureRecognizerDelegate;
@end

@implementation PLCMapView

@dynamic delegate;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void) sharedInit {
    self.oneFingerZoomRecognizer = [[BDDROneFingerZoomGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerZoomed:)];
    self.oneFingerZoomRecognizer.scaleFactor = 5.0f;
    self.oneFingerGestureRecognizerDelegate = [PLCMapViewInternalOneFingerGestureRecognizerDelegate new];
    self.oneFingerGestureRecognizerDelegate.mapView = self;
    self.oneFingerZoomRecognizer.delegate = self.oneFingerGestureRecognizerDelegate;
    [self resetScale];
    [self addGestureRecognizer:self.oneFingerZoomRecognizer];
}

- (void) oneFingerZoomed:(BDDROneFingerZoomGestureRecognizer *)recognizer {
    MKCoordinateSpan span = MKCoordinateSpanMake(self.lastRegion.span.latitudeDelta * recognizer.scale, self.lastRegion.span.longitudeDelta * recognizer.scale);
    self.region = MKCoordinateRegionMake(self.lastRegion.center, span);
}

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


- (void) resetScale {
    UIGestureRecognizerState state = self.oneFingerZoomRecognizer.state;
    if (state != UIGestureRecognizerStateBegan && state != UIGestureRecognizerStateChanged && state != UIGestureRecognizerStateEnded) {
        self.oneFingerZoomRecognizer.scale = 1.0f;
        self.lastRegion = self.region;
    }
}

@end
