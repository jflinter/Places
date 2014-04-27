//
//  PLCMapViewController.m
//  Places
//
//  Created by Cameron Spickert on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCMapViewController.h"
#import "PLCPlace.h"
#import "PLCPlaceStore.h"
#import "PLCPinAnnotationView.h"
#import "PLCMapView.h"
#import "PLCCalloutViewController.h"
#import "PLCCalloutTransitionAnimator.h"

static NSString * const PLCMapPinReuseIdentifier = @"PLCMapPinReuseIdentifier";

@interface PLCMapViewController () <MKMapViewDelegate, PLCPlaceStoreDelegate, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet PLCMapView *mapView;
@property (nonatomic, readonly) PLCPlaceStore *placeStore;
@property (nonatomic) CLLocation *savedLocation;

@end

@implementation PLCMapViewController

@synthesize placeStore = _placeStore;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.mapView showAnnotations:self.placeStore.allPlaces animated:NO];
    [self.mapView addAnnotations:self.placeStore.allPlaces];
    [self.mapView addGestureRecognizer:[self addPlaceGestureRecognizer]];
}

#pragma mark -
#pragma mark Map view delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:PLCMapPinReuseIdentifier];
    if (!annotationView) {
        PLCPinAnnotationView *pinAnnotation = [[PLCPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PLCMapPinReuseIdentifier];
        pinAnnotation.animatesDrop = YES;
        pinAnnotation.draggable = YES;
        pinAnnotation.canShowCallout = NO;
        annotationView = pinAnnotation;
    }
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState {
    if (newState == MKAnnotationViewDragStateEnding) {
        [self.placeStore save];
    }
}

- (void)mapView:(PLCMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if (self.presentedViewController == nil) {
        self.savedLocation = [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
    }

    [UIView animateWithDuration:0.3 animations:^{
        // we want to scroll the map such that the annotation view is centered horizontally and 50px above the bottom of the screen.

        CGFloat topPadding = 20; // the padding between the top of the map view and the desired top of the callout view
        CGFloat mapHeight = CGRectGetHeight(self.mapView.bounds);
        CGFloat paddingRatio = 0.5f - ((topPadding + calloutController.calloutView.frame.size.height + CGRectGetHeight(view.frame)) / mapHeight);

        CLLocationCoordinate2D center = view.annotation.coordinate;
        center.latitude -= self.mapView.region.span.latitudeDelta * paddingRatio;

        [self.mapView setCenterCoordinate:center animated:NO];
    }];

    [self presentViewController:[self instantiateCalloutControllerForAnnotationView:view] animated:YES completion:nil];
}

- (void)mapView:(PLCMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    [self dismissViewControllerAnimated:YES completion:^{
//        if (self.presentedViewController == nil && self.savedLocation) {
//            [mapView setCenterCoordinate:self.savedLocation.coordinate animated:YES];
//        }
    }];
}

- (void)mapView:(PLCMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    [self dismissViewControllerAnimated:YES completion:^{
        for (id<MKAnnotation> annotation in mapView.selectedAnnotations) {
            [mapView deselectAnnotation:annotation animated:YES];
        }
    }];
}

#pragma mark -
#pragma mark Place Store Delegate

- (void)placeStore:(PLCPlaceStore *)store didInsertPlace:(PLCPlace *)place
{
    [self.mapView addAnnotation:place];
    [self.mapView selectAnnotation:place animated:YES];
}

- (void)placeStore:(PLCPlaceStore *)store didRemovePlace:(PLCPlace *)place
{
    [self.mapView removeAnnotation:place];
}

#pragma mark -
#pragma mark Helpers

- (PLCPlaceStore *)placeStore
{
    if (!_placeStore) {
        _placeStore = [[PLCPlaceStore alloc] init];
        _placeStore.delegate = self;
    }
    return _placeStore;
}

- (UIGestureRecognizer *)addPlaceGestureRecognizer
{
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    recognizer.delegate = self;
    return recognizer;
}

- (void)longPressed:(UIGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint mapViewLocation = [sender locationInView:self.mapView];
        CLLocationCoordinate2D touchCoordinate = [self.mapView convertPoint:mapViewLocation
                                                       toCoordinateFromView:self.mapView];
        [self.placeStore insertPlaceAtCoordinate:touchCoordinate];
    }
}

- (PLCCalloutViewController *)instantiateCalloutControllerForAnnotationView:(MKAnnotationView *)annotationView
{
    PLCCalloutViewController *calloutController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PLCCalloutViewController class])];

    calloutController.annotationView = annotationView;
    calloutController.place = annotationView.annotation;
    calloutController.modalPresentationStyle = UIModalPresentationCustom;
    calloutController.transitioningDelegate = self;

    return calloutController;
}

#pragma mark -
#pragma mark UIViewControllerTransitioningDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    if ([presented isKindOfClass:[PLCCalloutViewController class]]) {
        return [[PLCCalloutTransitionAnimator alloc] init];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    if ([dismissed isKindOfClass:[PLCCalloutViewController class]]) {
        return [[PLCCalloutTransitionAnimator alloc] init];
    }
    return nil;
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.presentedViewController) {
        CGPoint point = [touch locationInView:self.presentedViewController.view];
        if ([self.presentedViewController.view pointInside:point withEvent:nil]) {
            return NO;
        }
    }
    return YES;
}

@end
