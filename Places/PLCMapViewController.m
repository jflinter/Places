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
#import "PLCSelectedMapCache.h"
#import "PLCSelectedMapViewModel.h"
#import "PLCPlaceCalloutViewModel.h"
#import <CoreLocation/CoreLocation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

static NSString *const PLCMapPinReuseIdentifier = @"PLCMapPinReuseIdentifier";
static CGFloat const PLCMapPanAnimationDuration = 0.3f;

@interface PLCMapViewController () <PLCMapViewDelegate, CLLocationManagerDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, weak, readwrite) PLCMapView *mapView;
@property (nonatomic, readonly) NSArray *calloutViewControllers;
@property (nonatomic, getter=isAddingPlace) BOOL addingPlace;
@property (nonatomic, getter=isAnimatingToPlace) BOOL animatingToPlace;
@property (nonatomic, getter=isSuspended) BOOL suspended;
@property (nonatomic) CLLocationManager *locationManager;
@end

@implementation PLCMapViewController

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
    [[RACObserve(mapView, userLocation) take:1] subscribeNext:^(MKUserLocation *userLocation) {
        if (userLocation) {
            userLocation.title = @"";
            if (!fequal(userLocation.coordinate.latitude, 0) && !fequal(userLocation.coordinate.longitude, 0)) {
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1600, 1600);
                [mapView setRegion:region animated:YES];
            }
        }
    }];
    mapView.delegate = self;
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView = mapView;
    [self.mapView addGestureRecognizer:[self addPlaceGestureRecognizer]];
    self.mapView.rotateEnabled = NO;
    self.mapView.showsPointsOfInterest = NO;

    [RACObserve(self.mapView, userLocation.location) subscribeNext:^(CLLocation *location) {
        self.viewModel.currentLocation = location;
    }];

    [RACObserve([PLCSelectedMapCache sharedInstance], selectedMap) subscribeNext:^(PLCMap *selectedMap) {
        [self.mapView removeAnnotations:self.mapView.annotations];
        if (selectedMap.activePlaces.count) {
            [self.mapView showAnnotations:selectedMap.activePlaces animated:YES];
        } else if (CLLocationCoordinate2DIsValid(self.mapView.userLocation.coordinate)) {
            [UIView animateWithDuration:PLCMapPanAnimationDuration
                                            animations:^{
                                              self.mapView.centerCoordinate = self.mapView.userLocation.coordinate;
                                            }];
        }
    }];
    
    [[[RACObserve([PLCSelectedMapCache sharedInstance], selectedMap)
       map:^(PLCMap *map) {
           return RACObserve(map, activePlaces);
       }]
      switchToLatest]
     subscribeNext:^(NSArray *places) {
         
           NSSet *currentAnnotations = [NSMutableSet setWithArray:[self.mapView.annotations.rac_sequence filter:^BOOL(id value) {
               return [value isKindOfClass:[PLCPlace class]];
           }].array];
             NSMutableSet *toAdd = [NSMutableSet setWithArray:places];
           [toAdd minusSet:currentAnnotations];
     
           NSMutableSet *toRemove = [currentAnnotations mutableCopy];
           [toRemove minusSet:[NSSet setWithArray:places]];
           [self.mapView addAnnotations:toAdd.allObjects];
         if ([toRemove containsObject:self.viewModel.selectedPlace]) {
             [self dismissCalloutViewController:self.calloutViewControllers.firstObject completion:^{
                 [self.mapView removeAnnotations:toRemove.allObjects];
             }];
         }
     }];
    
    [[[RACObserve(self, viewModel)
       map:^(PLCSelectedMapViewModel *viewModel) {
           return [RACObserve(viewModel, selectedPlace) distinctUntilChanged];
       }]
      switchToLatest] subscribeNext:^(PLCPlace *place) {
        [self dismissAllCalloutViewControllers];
        [self.mapView selectAnnotation:place animated:YES];
    }];
    self.view = self.mapView;
}

- (void)didBecomeActive:(__unused NSNotification *)notification {
    self.suspended = NO;
    self.mapView.showsUserLocation = YES;
}

- (void)willEnterBackground:(__unused NSNotification *)notification {
    self.suspended = YES;
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
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:PLCMapPinReuseIdentifier];
    if (!annotationView) {
        annotationView = [[PLCPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PLCMapPinReuseIdentifier];
    }
    return annotationView;
}

- (void)mapView:(__unused MKMapView *)mapView
        annotationView:(MKAnnotationView *)view
    didChangeDragState:(MKAnnotationViewDragState)newState
          fromOldState:(__unused MKAnnotationViewDragState)oldState {
    if (newState == MKAnnotationViewDragStateEnding) {
        [PLCPlaceStore updatePlace:(PLCPlace *)view.annotation withCoordinate:[view.annotation coordinate]];
    }
}

- (void)mapView:(PLCMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (view.annotation == mapView.userLocation) {
        return;
    }
    self.viewModel.selectedPlace = (PLCPlace *)view.annotation;
    [self dismissAllCalloutViewControllers];
    BOOL shouldEdit = self.isAddingPlace;
    void (^afterCallout)() = ^{
      PLCCalloutViewController *calloutViewController = [self instantiateCalloutControllerForAnnotation:view.annotation];
      [self presentCalloutViewController:calloutViewController fromAnnotationView:view forceEditing:shouldEdit];
    };

    BOOL const waitToShow = view.layer.animationKeys.count > 0;
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

- (void)mapView:(__unused PLCMapView *)mapView didDeselectAnnotationView:(__unused MKAnnotationView *)view {
    self.viewModel.selectedPlace = nil;
}

- (void)mapView:(PLCMapView *)mapView regionWillChangeAnimated:(__unused BOOL)animated {
    // Fixes a silly bug where this is called when the application becomes active
    if (self.suspended) {
        return;
    }
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
#pragma mark Helpers

- (UIGestureRecognizer *)addPlaceGestureRecognizer {
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    recognizer.delegate = self.mapView;
    return recognizer;
}

- (void)longPressed:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint mapViewLocation = [sender locationInView:self.mapView];
        CLLocationCoordinate2D touchCoordinate = [self.mapView convertPoint:mapViewLocation toCoordinateFromView:self.mapView];
        self.viewModel.selectedPlace = [self.viewModel addPlaceAtCoordinate:touchCoordinate];
    }
}

- (NSArray *)calloutViewControllers {
    return [self.childViewControllers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class = %@", [PLCCalloutViewController class]]];
}

- (PLCCalloutViewController *)existingCalloutViewControllerForAnnotationView:(MKAnnotationView *)annotationView {
    return [[self.calloutViewControllers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"view.superview = %@", annotationView]] firstObject];
}

- (PLCCalloutViewController *)instantiateCalloutControllerForAnnotation:(id<MKAnnotation>)annotation {
    PLCCalloutViewController *calloutController = [[UIStoryboard storyboardWithName:@"Places_phone" bundle:nil]
        instantiateViewControllerWithIdentifier:NSStringFromClass([PLCCalloutViewController class])];
    PLCPlaceCalloutViewModel *viewModel = [[PLCPlaceCalloutViewModel alloc] initWithParentViewModel:self.viewModel place:(PLCPlace *)annotation];
    calloutController.viewModel = viewModel;
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
                       if (![calloutViewController.viewModel hasCaption] || forceEditing) {
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

- (IBAction)dropPin:(__unused id)sender {
    [self determineLocation:^{
      PLCPlace *place = [PLCPlaceStore insertPlaceOntoMap:[PLCSelectedMapCache sharedInstance].selectedMap atCoordinate:self.mapView.userLocation.coordinate];
        self.viewModel.selectedPlace = place;
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
                                                                                   [PLCPlaceStore updatePlace:place withCoordinate:currentLocation.coordinate];
                                                                               }
                                                                           }
                                                                         }];
    }];
}

- (void)panToLocation:(CLLocation *)location animated:(BOOL)animated {
    [UIView animateWithDuration:(PLCMapPanAnimationDuration * animated)
                     animations:^{
                         self.mapView.centerCoordinate = location.coordinate;
                     }];
}

@end
