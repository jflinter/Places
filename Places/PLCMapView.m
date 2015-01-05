//
//  PLCMapView.m
//  Places
//
//  Created by Jack Flintermann on 4/19/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCMapView.h"
#import <BDDROneFingerZoomGestureRecognizer/BDDROneFingerZoomGestureRecognizer.h>

/*
 This object acts as the delegate for our one-finger zoom gesture recognizer.
 Normally the PLCMapView would handle this, but it already has to manage its private internal gesture recognizers, which causes issues. So this class acts as a "delegate proxy" of sorts to provide different behavior while remaining somewhat internal to the PLCMapView.
 */
@interface PLCMapViewInternalOneFingerGestureRecognizerDelegate : NSObject<UIGestureRecognizerDelegate>

// We want to hang on to the map view so that we can use its callout-avoiding logic.
// it's a weak reference to avoid retain cycles (note that the ownership pattern is the reverse
// of what is normally done here: the map view has a strong reference to its delegate, and the
// delegate has a weak reference back to it. It's odd, but the only way I could think to make
// it work.
@property(nonatomic, readwrite, weak)PLCMapView *mapView;
@end

@implementation PLCMapViewInternalOneFingerGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(__unused UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(__unused UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    return [self.mapView gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
}

@end


@interface PLCMapView()
@property(nonatomic, assign) CGFloat currentScale;
@property(nonatomic) BDDROneFingerZoomGestureRecognizer *oneFingerZoomRecognizer;
@property(nonatomic) PLCMapViewInternalOneFingerGestureRecognizerDelegate *oneFingerGestureRecognizerDelegate;
@end

@implementation PLCMapView

@dynamic delegate;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void) sharedInit {
    self.currentScale = 1.0f;
    self.oneFingerZoomRecognizer = [[BDDROneFingerZoomGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerZoomed:)];
    self.oneFingerZoomRecognizer.scaleFactor = 8.0f;
    PLCMapViewInternalOneFingerGestureRecognizerDelegate *delegate = [PLCMapViewInternalOneFingerGestureRecognizerDelegate new];
    self.oneFingerGestureRecognizerDelegate = delegate;
    self.oneFingerGestureRecognizerDelegate.mapView = self;
    self.oneFingerZoomRecognizer.delegate = self.oneFingerGestureRecognizerDelegate;
    [self addGestureRecognizer:self.oneFingerZoomRecognizer];
}

- (void) oneFingerZoomed:(BDDROneFingerZoomGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded: {
            CGFloat scaleRatio = recognizer.scale / self.currentScale;
            MKCoordinateSpan span = MKCoordinateSpanMake(self.region.span.latitudeDelta * scaleRatio, self.region.span.longitudeDelta * scaleRatio);
            self.region = MKCoordinateRegionMake(self.region.center, span);
            self.currentScale = recognizer.scale;
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
            self.currentScale = 1.0f;
            break;
    }
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(__unused UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
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
