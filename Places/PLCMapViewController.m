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
#import "PLCMapSelectionTransitionAnimator.h"
#import "PLCMapSelectionTableViewController.h"
#import "PLCMapSelectionViewController.h"
#import <INTULocationManager/INTULocationManager.h>
#import "PLCMap.h"
#import "PLCMapStore.h"
#import "PLCPlaceSearchTableViewController.h"
#import "PLCDatabase.h"
#import <CoreLocation/CoreLocation.h>
#import "PLCBlurredModalPresentationController.h"

static NSString * const PLCMapPinReuseIdentifier = @"PLCMapPinReuseIdentifier";
static CGFloat const PLCMapPanAnimationDuration = 0.3f;

@interface PLCMapViewController () <PLCMapViewDelegate, PLCPlaceStoreDelegate, PLCMapStoreDelegate, CLLocationManagerDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, weak, readwrite) IBOutlet PLCMapView *mapView;
@property (nonatomic, readonly) PLCPlaceStore *placeStore;
@property (nonatomic, readonly) NSArray *calloutViewControllers;
@property (nonatomic) BOOL determiningInitialLocation;
@property (nonatomic, getter=isAddingPlace) BOOL addingPlace;
@property (nonatomic, getter=isAnimatingToPlace) BOOL animatingToPlace;
@property (nonatomic) PLCMapSelectionTransitionAnimator *animator;
@property (nonatomic) BOOL chromeHidden;
@property (nonatomic) CLLocationManager *locationManager;
@end

@implementation PLCMapViewController

@synthesize placeStore = _placeStore;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
}

- (void)didBecomeActive:(NSNotification *)notification {
//    self.mapView.showsUserLocation = YES;
}

- (void)willEnterBackground:(NSNotification *)notification {
//    self.mapView.showsUserLocation = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupLocationServices];
    [self.mapView addAnnotations:self.placeStore.allPlaces];
    [self.mapView addGestureRecognizer:[self addPlaceGestureRecognizer]];
    self.mapView.rotateEnabled = NO;
    self.mapView.showsPointsOfInterest = NO;
    self.navigationItem.title = [PLCMapStore sharedInstance].selectedMap.name;
    [PLCMapStore sharedInstance].delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.chromeHidden = YES;
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setChromeHidden:NO animated:YES];
        CLLocationManager *manager = [[INTULocationManager sharedInstance] valueForKey:@"locationManager"];
        [manager requestWhenInUseAuthorization];
    });
}

#pragma mark -
#pragma mark Map view delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
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
    [self setChromeHidden:YES animated:YES];
    [self dismissAllCalloutViewControllers];
    
    void (^afterCallout)() = ^{
        PLCCalloutViewController *calloutViewController = [self instantiateCalloutControllerForAnnotation:view.annotation];
        [self presentCalloutViewController:calloutViewController fromAnnotationView:view];
    };

    BOOL const waitToShow = self.isAddingPlace;
    NSTimeInterval animationDuration = waitToShow ? [PLCPinAnnotationView pinDropAnimationDuration] : PLCMapPanAnimationDuration;
    self.animatingToPlace = YES;
    
    CGSize size = [PLCCalloutViewController calloutSize];
    CGFloat topPadding = (CGRectGetWidth(mapView.frame) - size.width) / 2;
    CGFloat difference = CGRectGetHeight(mapView.frame) / 2 - (size.height + topPadding);
    CGPoint point = CGPointMake(8, difference);
    CLLocationCoordinate2D coord = [self.mapView convertPoint:point toCoordinateFromView:view];

    [UIView animateWithDuration:animationDuration animations:^{
        [self.mapView setCenterCoordinate:coord animated:NO];
    } completion:^(BOOL finished) {
        self.animatingToPlace = NO;
        if (finished && waitToShow) {
            afterCallout();
        }
    }];

    if (!waitToShow) {
        afterCallout();
    }
}

- (void)mapView:(PLCMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        PLCCalloutViewController *calloutViewController = [self existingCalloutViewControllerForAnnotationView:view];
        if (calloutViewController) {
            [self dismissCalloutViewController:calloutViewController completion:nil];
        }
        if (!self.mapView.selectedAnnotations.count) {
            [self setChromeHidden:NO animated:YES];
        }
    });
}

- (void)mapView:(PLCMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
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

- (NSArray *)presentedCalloutViewControllersForMapView:(PLCMapView *)mapView
{
    return self.calloutViewControllers;
}

#pragma mark -
#pragma mark Place Store Delegate

- (void)placeStore:(PLCPlaceStore *)store didInsertPlace:(PLCPlace *)place new:(BOOL)isNew
{
    self.addingPlace = YES;

    [self.mapView addAnnotation:place];
    if (isNew) {
        [self.mapView selectAnnotation:place animated:YES];
    }

    self.addingPlace = NO;
}

- (void)placeStore:(PLCPlaceStore *)store didRemovePlace:(PLCPlace *)place
{
    MKAnnotationView *view = [self.mapView viewForAnnotation:place];
    PLCCalloutViewController *calloutViewController = [self existingCalloutViewControllerForAnnotationView:view];
    if (calloutViewController) {
        [self dismissCalloutViewController:calloutViewController completion:^{
            if ([self.mapView.annotations containsObject:place]) {
                [self.mapView removeAnnotation:place];
            }
        }];
    }
    else {
        [self.mapView removeAnnotation:place];
    }
}

#pragma mark -
#pragma mark PLCMapStoreDelegate

- (void)mapStore:(PLCMapStore *)store didChangeMap:(PLCMap *)map {
    [self.mapView removeAnnotations:self.mapView.annotations];
    NSArray *annotations = [map activePlaces];
    [self.mapView addAnnotations:annotations];
    [self.mapView showAnnotations:annotations animated:YES];
    self.navigationItem.title = map.name;
}

#pragma mark -
#pragma mark Helpers

- (PLCPlaceStore *)placeStore
{
    if (!_placeStore) {
        _placeStore = [PLCPlaceStore sharedInstance];
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
    calloutController.place = (PLCPlace *)annotation;
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
        if (!calloutViewController.place.caption || [calloutViewController.place.caption isEqualToString:@""]) {
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
    if (self.placeStore.allPlaces.count) {
        [self.mapView showAnnotations:self.placeStore.allPlaces animated:NO];
    }
    else {
        self.determiningInitialLocation = YES;
    }
//    self.mapView.showsUserLocation = YES;
}

- (void) determineLocation:(void (^)(void))completion {
    [self dismissAllCalloutViewControllers];
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            if (completion) {
                completion();
            }
        }
            break;
        case kCLAuthorizationStatusNotDetermined: {
            CLLocationManager *manager = [[INTULocationManager sharedInstance] valueForKey:@"locationManager"];
            [manager requestWhenInUseAuthorization];
        }
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

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            self.mapView.showsUserLocation = YES;
            return;
        }
        default: {
            self.mapView.showsUserLocation = NO;
        }
    }
}

- (IBAction)openSearch:(id)sender {
    
}


- (IBAction)showLocation:(id)sender {
    [self determineLocation:^{
        [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyBlock timeout:2 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
            if (status == INTULocationStatusSuccess) {
                [UIView animateWithDuration:PLCMapPanAnimationDuration animations:^{
                    [self.mapView setCenterCoordinate:currentLocation.coordinate
                                             animated:NO];
                }];
            }
            else {
                NSString *title = NSLocalizedString(@"Couldn't determine location", nil);
                NSString *message = NSLocalizedString(@"Try again when you have a better signal.", nil);
                [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
    }];
}

- (IBAction)dropPin:(id)sender {
    [self determineLocation:^{
        PLCPlace *place = [self.placeStore insertPlaceAtCoordinate:self.mapView.userLocation.coordinate];
        [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyHouse timeout:180 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
            // in case the current location's accuracy isn't very good, we want to add the place immediately but then asynchronously try and improve it.
            if (status == INTULocationStatusSuccess) {
                if (place.coordinate.latitude != currentLocation.coordinate.latitude || place.coordinate.longitude != currentLocation.coordinate.longitude) {
                    place.coordinate = currentLocation.coordinate;
                    [self.placeStore save];
                }
            }
        }];
    }];
}

- (IBAction)shareMap:(id)sender {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[[PLCMapStore sharedInstance].selectedMap shareURL]] applicationActivities:nil];
    //exclude the airdrop action because it's incredibly fucking slow and noone uses it
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint,
                                                     UIActivityTypeAirDrop];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    userLocation.title = @"";
    
    // This is just for initial map load, when we want to show the user's location in the absence of any places on the map.
    if (self.determiningInitialLocation && !self.calloutViewControllers.count) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1600, 1600);
        [self.mapView setRegion:region animated:YES];
        self.determiningInitialLocation = NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.destinationViewController isKindOfClass:[PLCMapSelectionViewController class]]) {
        [self dismissAllCalloutViewControllers];
        PLCMapSelectionViewController *controller = (PLCMapSelectionViewController *)segue.destinationViewController;
        self.animator = [[PLCMapSelectionTransitionAnimator alloc] initWithParentViewController:controller];
        self.animator.presenting = YES;
        controller.transitioningDelegate = self.animator;
        controller.modalPresentationStyle = UIModalPresentationCustom;
    }
}

- (IBAction)beginSearch:(id)sender {
    PLCPlaceSearchTableViewController *tableViewController = [PLCPlaceSearchTableViewController new];
    tableViewController.searchRegion = self.mapView.region;
    tableViewController.transitioningDelegate = self;
    tableViewController.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:tableViewController animated:YES completion:nil];
}

- (void)setChromeHidden:(BOOL)chromeHidden {
    [self setChromeHidden:chromeHidden animated:NO];
}

- (void)setChromeHidden:(BOOL)chromeHidden
               animated:(BOOL)animated {
    if (_chromeHidden != chromeHidden) {
        _chromeHidden = chromeHidden;
        [self.navigationController setToolbarHidden:chromeHidden animated:animated];
        if (animated) {
            [[UIApplication sharedApplication] setStatusBarHidden:chromeHidden withAnimation:UIStatusBarAnimationSlide];
        }
        else {
            [[UIApplication sharedApplication] setStatusBarHidden:chromeHidden];
        }
        [self.navigationController setNavigationBarHidden:chromeHidden animated:animated];
    }
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    if ([presented isKindOfClass:[PLCPlaceSearchTableViewController class]]) {
        return [[PLCBlurredModalPresentationController alloc] initWithPresentedViewController:presented presentingViewController:self];
    }
    return nil;
}

@end
