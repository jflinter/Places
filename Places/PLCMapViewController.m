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
#import "PLCCalloutView.h"

static NSString * const PLCMapPinReuseIdentifier = @"PLCMapPinReuseIdentifier";

@interface PLCMapViewController () <MKMapViewDelegate, PLCPlaceStoreDelegate>

@property (nonatomic, weak) IBOutlet PLCMapView *mapView;
@property (nonatomic, readonly) PLCPlaceStore *placeStore;
@property (nonatomic, weak) PLCCalloutViewController *calloutViewController;

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

- (void)mapView:(PLCMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    // we want to scroll the map such that the annotation view is centered horizontally and 50px above the bottom of the screen.
    if (mapView.activeAnnotationView && view != mapView.activeAnnotationView) {
        [self.mapView deselectAnnotation:mapView.activeAnnotationView.annotation animated:YES];
    }
    CGFloat bottomPadding = 50;
    CGFloat mapHeight = CGRectGetHeight(mapView.frame);
    CGFloat paddingRatio = 0.5f - bottomPadding / mapHeight;
    CGFloat animationDuration = 0.1f;
    CLLocationCoordinate2D center = view.annotation.coordinate;
    center.latitude += self.mapView.region.span.latitudeDelta * paddingRatio;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.mapView setCenterCoordinate:center animated:YES];
    } completion:^(BOOL finished) {
        self.mapView.activeAnnotationView = view;
    }];
    PLCCalloutViewController *calloutController = [self instantiateCalloutController];
    calloutController.place = view.annotation;
    self.calloutViewController = calloutController;
    [self addChildViewController:calloutController];
    mapView.activeCalloutView = calloutController.calloutView;
    [calloutController.calloutView showInView:view];
}

- (void)mapView:(PLCMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    mapView.activeAnnotationView = nil;
    mapView.activeCalloutView = nil;
    [self.calloutViewController.calloutView hide];
    [self.calloutViewController removeFromParentViewController];
    self.calloutViewController = nil;
}

- (void)mapView:(PLCMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    if (mapView.activeAnnotationView) {
        [self.mapView deselectAnnotation:mapView.activeAnnotationView.annotation animated:YES];
    }
}

#pragma mark -
#pragma mark Place Store Delegate
- (void)placeStore:(PLCPlaceStore *)store
    didInsertPlace:(PLCPlace *)place {
    [self.mapView addAnnotation:place];
    [self.mapView selectAnnotation:place animated:YES];
}

- (void)placeStore:(PLCPlaceStore *)store
    didRemovePlace:(PLCPlace *)place {
    [self.mapView removeAnnotation:place];
}

#pragma mark -
#pragma mark Helpers

- (PLCPlaceStore *)placeStore {
    if (!_placeStore) {
        _placeStore = [[PLCPlaceStore alloc] init];
        _placeStore.delegate = self;
    }
    return _placeStore;
}

- (UIGestureRecognizer *)addPlaceGestureRecognizer {
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    recognizer.delegate = self.mapView;
    return recognizer;
}

- (void)longPressed:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint mapViewLocation = [sender locationInView:self.mapView];
        CLLocationCoordinate2D touchCoordinate = [self.mapView convertPoint:mapViewLocation
                                                       toCoordinateFromView:self.mapView];
        [self.placeStore insertPlaceAtCoordinate:touchCoordinate];
    }
}

- (PLCCalloutViewController *) instantiateCalloutController {
    return [[self storyboard] instantiateViewControllerWithIdentifier:@"PLCCalloutViewController"];
}


@end
