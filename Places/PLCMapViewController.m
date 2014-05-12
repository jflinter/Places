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
#import "PLCCalloutTransitionContext.h"
#import <INTULocationManager/INTULocationManager.h>

static NSString * const PLCMapPinReuseIdentifier = @"PLCMapPinReuseIdentifier";
static CGFloat const PLCMapPanAnimationDuration = 0.3f;

@interface PLCMapViewController () <PLCMapViewDelegate, PLCPlaceStoreDelegate, UIViewControllerTransitioningDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet PLCMapView *mapView;
@property (nonatomic, readonly) PLCPlaceStore *placeStore;
@property (nonatomic, readonly) NSArray *calloutViewControllers;
@property (nonatomic, readwrite, strong) CLLocationManager *locationManager;
@property (nonatomic) BOOL initiallyAuthorized;
@property (nonatomic) BOOL determiningInitialLocation;

@end

@implementation PLCMapViewController

@synthesize placeStore = _placeStore;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.mapView showAnnotations:self.placeStore.allPlaces animated:NO];
    [self.mapView addAnnotations:self.placeStore.allPlaces];
    [self.mapView addGestureRecognizer:[self addPlaceGestureRecognizer]];
    [self setupLocationServices];
}

#pragma mark -
#pragma mark Map view delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
    if (annotation == mapView.userLocation) {
        return nil; // this makes the blue dot
    }
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
    if (view.annotation == mapView.userLocation) {
        return;
    }

    [self dismissAllCalloutViewControllers];
    
    void (^afterCallout)() = ^{
        PLCCalloutViewController *calloutViewController = [self instantiateCalloutControllerForAnnotation:view.annotation];
        [self presentCalloutViewController:calloutViewController fromAnnotationView:view];
    };
    
    BOOL waitToShow = view.annotation == self.placeStore.justAddedPlace;
    NSTimeInterval animationDuration = waitToShow ? [PLCPinAnnotationView pinDropAnimationDuration] : PLCMapPanAnimationDuration;
    
    [UIView animateWithDuration:animationDuration animations:^{
        // we want to scroll the map such that the annotation view is centered horizontally and 50px above the bottom of the screen.

        CGFloat topPadding = 10; // the padding between the top of the map view and the desired top of the callout view
        CGFloat mapHeight = CGRectGetHeight(self.mapView.bounds);
        CGFloat paddingRatio = 0.5f - ((topPadding + [PLCCalloutViewController calloutSize].height + CGRectGetHeight(view.frame)) / mapHeight);

        CLLocationCoordinate2D center = view.annotation.coordinate;
        center.latitude -= self.mapView.region.span.latitudeDelta * paddingRatio;

        [self.mapView setCenterCoordinate:center animated:NO];
    } completion:^(BOOL finished) {
        if (finished && waitToShow) {
            afterCallout();
        }
    }];

    if (!waitToShow) {
        PLCCalloutViewController *calloutViewController = [self instantiateCalloutControllerForAnnotation:view.annotation];
        [self presentCalloutViewController:calloutViewController fromAnnotationView:view];
    }
}

- (void)mapView:(PLCMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    PLCCalloutViewController *calloutViewController = [self existingCalloutViewControllerForAnnotationView:view];
    if (calloutViewController) {
        [self dismissCalloutViewController:calloutViewController completion:nil];
    }
}

- (void)mapView:(PLCMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    // fixes a weird bug where the region changes when presenting an image picker
    if ([self.presentedViewController isKindOfClass:[UIImagePickerController class]]) {
        return;
    }
    if (!animated) {
        for (id<MKAnnotation> annotation in [mapView.selectedAnnotations copy]) {
            [mapView deselectAnnotation:annotation animated:YES];
        }
    }
}

- (NSArray *)presentedCalloutViewControllersForMapView:(PLCMapView *)mapView
{
    return self.calloutViewControllers;
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
    MKAnnotationView *view = [self.mapView viewForAnnotation:place];
    PLCCalloutViewController *calloutViewController = [self existingCalloutViewControllerForAnnotationView:view];
    if (calloutViewController) {
        [self dismissCalloutViewController:calloutViewController completion:^{
            [self.mapView removeAnnotation:place];
        }];
    }
    else {
        [self.mapView removeAnnotation:place];
    }
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
    recognizer.delegate = self.mapView;
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

- (NSArray *)calloutViewControllers
{
    return [self.childViewControllers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class = %@", [PLCCalloutViewController class]]];
}

- (PLCCalloutViewController *)existingCalloutViewControllerForAnnotationView:(MKAnnotationView *)annotationView
{
    return [[self.calloutViewControllers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"view.superview = %@", annotationView]] firstObject];
}

- (PLCCalloutViewController *)instantiateCalloutControllerForAnnotation:(id<MKAnnotation>)annotation
{
    PLCCalloutViewController *calloutController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PLCCalloutViewController class])];
    calloutController.place = annotation;
    return calloutController;
}

#pragma mark -
#pragma mark Callout presentation methods

- (void)presentCalloutViewController:(PLCCalloutViewController *)calloutViewController fromAnnotationView:(MKAnnotationView *)annotationView
{
    [self addChildViewController:calloutViewController];

    PLCCalloutTransitionContext *transitionContext = [[PLCCalloutTransitionContext alloc] initWithOperation:PLCCalloutTransitionContextOperationPresent];
    transitionContext.mapViewController = self;
    transitionContext.calloutViewController = calloutViewController;
    transitionContext.containerView = annotationView;

    PLCCalloutTransitionAnimator *animator = [[PLCCalloutTransitionAnimator alloc] init];

    [animator animateTransition:transitionContext completion:^{
        if (!calloutViewController.place.caption) {
            [calloutViewController editCaption];
        }
    }];
}

- (void)dismissCalloutViewController:(PLCCalloutViewController *)calloutViewController
                          completion:(void (^)())completion
{
    [calloutViewController removeFromParentViewController];

    PLCCalloutTransitionContext *transitionContext = [[PLCCalloutTransitionContext alloc] initWithOperation:PLCCalloutTransitionContextOperationDismiss];
    transitionContext.mapViewController = self;
    transitionContext.calloutViewController = calloutViewController;
    transitionContext.containerView = calloutViewController.view.superview;

    PLCCalloutTransitionAnimator *animator = [[PLCCalloutTransitionAnimator alloc] init];
    [animator animateTransition:transitionContext completion:completion];
}

- (void)dismissAllCalloutViewControllers
{
    for (PLCCalloutViewController *calloutViewController in [self.calloutViewControllers copy]) {
        [self dismissCalloutViewController:calloutViewController completion:nil];
    }
}

- (void)setupLocationServices {
    self.initiallyAuthorized = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized;
    self.mapView.showsUserLocation = self.initiallyAuthorized;
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(locationButtonLongPressed:)];
    [self.locationButton addGestureRecognizer:longPressGestureRecognizer];
}

- (void) determineLocation:(void (^)(void))completion {
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorized: {
            if (completion) {
                completion();
            }
        }
            break;
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager startUpdatingLocation];
            break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted: {
            NSString *title = NSLocalizedString(@"Location Services Required", nil);
            NSString *message = NSLocalizedString(@"To show your location, open the Settings app, go to Privacy -> Location Services, and turn Places to \"on\".", nil);
            [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
            break;
    }
}

- (IBAction)showLocation:(id)sender {
    [self dismissAllCalloutViewControllers];
    [self determineLocation:^{
        [UIView animateWithDuration:PLCMapPanAnimationDuration animations:^{
            [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate
                                     animated:NO];
        }];
    }];
}

- (void)locationButtonLongPressed:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self determineLocation:^{
            PLCPlace *place = [self.placeStore insertPlaceAtCoordinate:self.mapView.userLocation.coordinate];
            [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyHouse timeout:180 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                if (status == INTULocationStatusSuccess) {
                    if (place.coordinate.latitude != currentLocation.coordinate.latitude || place.coordinate.longitude != currentLocation.coordinate.longitude) {
                        place.coordinate = currentLocation.coordinate;
                        [self.placeStore save];
                    }
                }
            }];
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (self.initiallyAuthorized) {
        return;
    }
    if (status == kCLAuthorizationStatusAuthorized) {
        [self.locationManager stopUpdatingLocation];
        self.mapView.showsUserLocation = YES;
        self.determiningInitialLocation = YES;
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    [mapView viewForAnnotation:userLocation].enabled = NO;
    if (self.determiningInitialLocation) {
        [self dismissAllCalloutViewControllers];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1600, 1600);
        [self.mapView setRegion:region animated:YES];
        self.determiningInitialLocation = NO;
    }
}


@end
