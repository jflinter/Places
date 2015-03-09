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
#import "PLCMap.h"
#import "PLCMapStore.h"
#import "PLCDatabase.h"
#import <CoreLocation/CoreLocation.h>

static NSString *const PLCMapPinReuseIdentifier = @"PLCMapPinReuseIdentifier";
static CGFloat const PLCMapPanAnimationDuration = 0.3f;

@interface PLCMapViewController () <PLCMapViewDelegate,
                                    PLCPlaceStoreDelegate,
                                    PLCMapStoreDelegate,
                                    CLLocationManagerDelegate,
                                    UIViewControllerTransitioningDelegate>

@property (nonatomic, weak, readwrite) PLCMapView *mapView;
@property (nonatomic, readonly) PLCPlaceStore *placeStore;
@property (nonatomic, readonly) NSArray *calloutViewControllers;
@property (nonatomic) BOOL determiningInitialLocation;
@property (nonatomic, getter=isAddingPlace) BOOL addingPlace;
@property (nonatomic, getter=isAnimatingToPlace) BOOL animatingToPlace;
@property (nonatomic) CLLocationManager *locationManager;
@end

@implementation PLCMapViewController

@synthesize placeStore = _placeStore;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
}

- (void)loadView {
    PLCMapView *mapView = [PLCMapView new];
    mapView.delegate = self;
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView = mapView;
    [self setupLocationServices];
    [self.mapView addAnnotations:self.placeStore.allPlaces];
    [self.mapView addGestureRecognizer:[self addPlaceGestureRecognizer]];
    self.mapView.rotateEnabled = NO;
    self.mapView.showsPointsOfInterest = NO;
    self.navigationItem.title = [PLCMapStore sharedInstance].selectedMap.name;
    [PLCMapStore sharedInstance].delegate = self;
    self.view = self.mapView;
}

- (void)didBecomeActive:(__unused NSNotification *)notification {
    self.mapView.showsUserLocation = YES;
}

- (void)willEnterBackground:(__unused NSNotification *)notification {
    self.mapView.showsUserLocation = NO;
}

- (void)dealloc {
    _locationManager.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      CLLocationManager *manager = [[INTULocationManager sharedInstance] valueForKey:NSStringFromSelector(@selector(locationManager))];
      [manager requestWhenInUseAuthorization];
    });
}

#pragma mark -
#pragma mark Map view delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (annotation == mapView.userLocation) {
        return nil; // this makes the blue dot
    }
    PLCPlace *place = (PLCPlace *)annotation;
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:PLCMapPinReuseIdentifier];
    if (!annotationView) {
        PLCPinAnnotationView *pinAnnotation = [[PLCPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PLCMapPinReuseIdentifier];
        pinAnnotation.animatesDrop = YES;
        pinAnnotation.draggable = YES;
        pinAnnotation.canShowCallout = NO;
        MKPinAnnotationColor color;
        switch (place.type) {
        case PLCPlaceTypeDo:
        case PLCPlaceTypeDrink:
        case PLCPlaceTypeEat:
            color = MKPinAnnotationColorRed;
        }
        pinAnnotation.pinColor = color;
        annotationView = pinAnnotation;
    }
    return annotationView;
}

- (void)mapView:(__unused MKMapView *)mapView
        annotationView:(__unused MKAnnotationView *)view
    didChangeDragState:(MKAnnotationViewDragState)newState
          fromOldState:(__unused MKAnnotationViewDragState)oldState {
    if (newState == MKAnnotationViewDragStateEnding) {
        [self.placeStore save];
    }
}

- (void)mapView:(PLCMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (view.annotation == mapView.userLocation) {
        return;
    }
    [self dismissAllCalloutViewControllers];
    BOOL shouldEdit = self.isAddingPlace;
    void (^afterCallout)() = ^{
      PLCCalloutViewController *calloutViewController = [self instantiateCalloutControllerForAnnotation:view.annotation];
      [self presentCalloutViewController:calloutViewController fromAnnotationView:view forceEditing:shouldEdit];
    };

    BOOL const waitToShow = self.isAddingPlace;
    NSTimeInterval animationDuration = waitToShow ? [PLCPinAnnotationView pinDropAnimationDuration] : PLCMapPanAnimationDuration;
    self.animatingToPlace = YES;

    CGSize size = [PLCCalloutViewController calloutSize];
    CGFloat topPadding = (CGRectGetWidth(mapView.frame) - size.width) / 2;
    CGFloat difference = CGRectGetHeight(mapView.frame) / 2 - (size.height + topPadding);
    CGPoint point = CGPointMake(8, difference);
    CLLocationCoordinate2D coord = [self.mapView convertPoint:point toCoordinateFromView:view];

    [UIView animateWithDuration:animationDuration
        animations:^{
          [self.mapView setCenterCoordinate:coord animated:NO];
        }
        completion:^(BOOL finished) {
          self.animatingToPlace = NO;
          if (finished && waitToShow) {
              afterCallout();
          }
        }];

    if (!waitToShow) {
        afterCallout();
    }
}

- (void)mapView:(__unused PLCMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    dispatch_async(dispatch_get_main_queue(), ^{
      PLCCalloutViewController *calloutViewController = [self existingCalloutViewControllerForAnnotationView:view];
      if (calloutViewController) {
          [self dismissCalloutViewController:calloutViewController completion:nil];
      }
    });
}

- (void)mapView:(PLCMapView *)mapView regionWillChangeAnimated:(__unused BOOL)animated {
    // fixes a weird bug where the region changes when presenting an image picker
    if ([self.presentedViewController isKindOfClass:[UIImagePickerController class]]) {
        return;
    }
    if (!self.animatingToPlace) {
        for (id<MKAnnotation> annotation in [mapView.selectedAnnotations copy]) {
            [mapView deselectAnnotation:annotation animated:YES];
        }
    }
}

- (NSArray *)presentedCalloutViewControllersForMapView:(__unused PLCMapView *)mapView {
    return self.calloutViewControllers;
}

#pragma mark -
#pragma mark Place Store Delegate

- (void)placeStore:(__unused PLCPlaceStore *)store didInsertPlace:(PLCPlace *)place new:(BOOL)isNew {
    self.addingPlace = YES;

    [self.mapView addAnnotation:place];
    if (isNew) {
        [self.mapView selectAnnotation:place animated:YES];
    }

    self.addingPlace = NO;
}

- (void)placeStore:(__unused PLCPlaceStore *)store didRemovePlace:(PLCPlace *)place {
    MKAnnotationView *view = [self.mapView viewForAnnotation:place];
    PLCCalloutViewController *calloutViewController = [self existingCalloutViewControllerForAnnotationView:view];
    if (calloutViewController) {
        [self dismissCalloutViewController:calloutViewController
                                completion:^{
                                  if ([self.mapView.annotations containsObject:place]) {
                                      [self.mapView removeAnnotation:place];
                                  }
                                }];
    } else {
        [self.mapView removeAnnotation:place];
    }
}

#pragma mark -
#pragma mark PLCMapStoreDelegate

- (void)mapStore:(__unused PLCMapStore *)store didChangeMap:(PLCMap *)map {
    [self.mapView removeAnnotations:self.mapView.annotations];
    NSArray *annotations = [map activePlaces];
    if (annotations.count) {
        [self.mapView addAnnotations:annotations];
        [self.mapView showAnnotations:annotations animated:YES];
    } else if (CLLocationCoordinate2DIsValid(self.mapView.userLocation.coordinate)) {
        [UIView animateWithDuration:PLCMapPanAnimationDuration
                         animations:^{
                           self.mapView.centerCoordinate = self.mapView.userLocation.coordinate;
                         }];
    }
    self.navigationItem.title = map.name;
}

#pragma mark -
#pragma mark Helpers

- (PLCPlaceStore *)placeStore {
    if (!_placeStore) {
        _placeStore = [PLCPlaceStore sharedInstance];
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
        CLLocationCoordinate2D touchCoordinate = [self.mapView convertPoint:mapViewLocation toCoordinateFromView:self.mapView];
        [self.placeStore insertPlaceAtCoordinate:touchCoordinate];
    }
}

- (NSArray *)calloutViewControllers {
    return [self.childViewControllers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class = %@", [PLCCalloutViewController class]]];
}

- (PLCCalloutViewController *)existingCalloutViewControllerForAnnotationView:(MKAnnotationView *)annotationView {
    return [[self.calloutViewControllers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"view.superview = %@", annotationView]] firstObject];
}

- (PLCCalloutViewController *)instantiateCalloutControllerForAnnotation:(id<MKAnnotation>)annotation {
    PLCCalloutViewController *calloutController = [[UIStoryboard storyboardWithName:@"Places_phone" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([PLCCalloutViewController class])];
    calloutController.place = (PLCPlace *)annotation;
    return calloutController;
}

#pragma mark -
#pragma mark Callout presentation methods

- (void)presentCalloutViewController:(PLCCalloutViewController *)calloutViewController
                  fromAnnotationView:(MKAnnotationView *)annotationView
                        forceEditing:(BOOL)forceEditing {
    [self addChildViewController:calloutViewController];

    PLCCalloutTransitionContext *transitionContext = [[PLCCalloutTransitionContext alloc] initWithOperation:PLCCalloutTransitionContextOperationPresent];
    transitionContext.mapViewController = self;
    transitionContext.calloutViewController = calloutViewController;
    transitionContext.containerView = annotationView;

    PLCCalloutTransitionAnimator *animator = [[PLCCalloutTransitionAnimator alloc] init];

    [animator animateTransition:transitionContext
                     completion:^{
                       if (((!calloutViewController.place.caption || [calloutViewController.place.caption isEqualToString:@""]) &&
                            !calloutViewController.place.image && !calloutViewController.place.imageId) ||
                           forceEditing) {
                           [calloutViewController editCaption];
                       }
                     }];
}

- (void)dismissCalloutViewController:(PLCCalloutViewController *)calloutViewController completion:(void (^)())completion {
    [calloutViewController removeFromParentViewController];

    PLCCalloutTransitionContext *transitionContext = [[PLCCalloutTransitionContext alloc] initWithOperation:PLCCalloutTransitionContextOperationDismiss];
    transitionContext.mapViewController = self;
    transitionContext.calloutViewController = calloutViewController;
    transitionContext.containerView = calloutViewController.view.superview;

    PLCCalloutTransitionAnimator *animator = [[PLCCalloutTransitionAnimator alloc] init];
    [animator animateTransition:transitionContext completion:completion];
}

- (void)dismissAllCalloutViewControllers {
    for (PLCCalloutViewController *calloutViewController in [self.calloutViewControllers copy]) {
        [self dismissCalloutViewController:calloutViewController completion:nil];
    }
}

- (void)setupLocationServices {
    if (self.placeStore.allPlaces.count) {
        [self.mapView showAnnotations:self.placeStore.allPlaces animated:NO];
    } else {
        self.determiningInitialLocation = YES;
    }
    //    self.mapView.showsUserLocation = YES;
}

- (void)determineLocation:(void (^)(void))completion {
    [self dismissAllCalloutViewControllers];
    switch ([CLLocationManager authorizationStatus]) {
    case kCLAuthorizationStatusAuthorizedWhenInUse:
    case kCLAuthorizationStatusAuthorizedAlways: {
        if (completion) {
            completion();
        }
    } break;
    case kCLAuthorizationStatusNotDetermined: {
        CLLocationManager *manager = [[INTULocationManager sharedInstance] valueForKey:NSStringFromSelector(@selector(locationManager))];
        [manager requestWhenInUseAuthorization];
    } break;
    case kCLAuthorizationStatusDenied:
    case kCLAuthorizationStatusRestricted: {
        NSString *title = NSLocalizedString(@"Location Services Required", nil);
        NSString *message =
            NSLocalizedString(@"To show your location, open the Settings app, go to Privacy -> Location Services, and turn Places to \"on\".", nil);
        [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    } break;
    }
}

- (void)locationManager:(__unused CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
    case kCLAuthorizationStatusAuthorizedWhenInUse:
    case kCLAuthorizationStatusAuthorizedAlways: {
        self.mapView.showsUserLocation = YES;
        return;
    }
    default: { self.mapView.showsUserLocation = NO; }
    }
}

- (IBAction)showLocation:(__unused id)sender {
    if (CLLocationCoordinate2DIsValid(self.mapView.userLocation.coordinate)) {
        [UIView animateWithDuration:PLCMapPanAnimationDuration
                         animations:^{
                           self.mapView.centerCoordinate = self.mapView.userLocation.coordinate;
                         }];
        return;
    }
    [self determineLocation:^{
      [[INTULocationManager sharedInstance]
          requestLocationWithDesiredAccuracy:INTULocationAccuracyBlock
                                     timeout:2
                                       block:^(CLLocation *currentLocation,
                                               __unused INTULocationAccuracy achievedAccuracy,
                                               __unused INTULocationStatus status) {
                                         if (status == INTULocationStatusSuccess) {
                                             [UIView animateWithDuration:PLCMapPanAnimationDuration
                                                              animations:^{
                                                                [self.mapView setCenterCoordinate:currentLocation.coordinate animated:NO];
                                                              }];
                                         } else {
                                             NSString *title = NSLocalizedString(@"Couldn't determine location", nil);
                                             NSString *message = NSLocalizedString(@"Try again when you have a better signal.", nil);
                                             [[[UIAlertView alloc] initWithTitle:title
                                                                         message:message
                                                                        delegate:nil
                                                               cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                               otherButtonTitles:nil] show];
                                         }
                                       }];
    }];
}

- (IBAction)dropPin:(__unused id)sender {
    [self determineLocation:^{
      PLCPlace *place = [self.placeStore insertPlaceAtCoordinate:self.mapView.userLocation.coordinate];
      [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyHouse
                                                                       timeout:180
                                                                         block:^(CLLocation *currentLocation,
                                                                                 __unused INTULocationAccuracy achievedAccuracy,
                                                                                 __unused INTULocationStatus status) {
                                                                           // in case the current location's accuracy isn't very good, we want to add the
                                                                           // place immediately but then
                                                                           // asynchronously try and improve it.
                                                                           if (status == INTULocationStatusSuccess) {
                                                                               if (!fequal(place.coordinate.latitude, currentLocation.coordinate.latitude) ||
                                                                                   !fequal(place.coordinate.longitude, currentLocation.coordinate.longitude)) {
                                                                                   place.coordinate = currentLocation.coordinate;
                                                                                   [self.placeStore save];
                                                                               }
                                                                           }
                                                                         }];
    }];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    userLocation.title = @"";

    // This is just for initial map load, when we want to show the user's location in the absence of any places on the map.
    if (self.determiningInitialLocation && !self.calloutViewControllers.count) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1600, 1600);
        [mapView setRegion:region animated:YES];
        self.determiningInitialLocation = NO;
    }
}

@end
