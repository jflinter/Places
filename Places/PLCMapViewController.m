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

static NSString * const PLCMapPinReuseIdentifier = @"PLCMapPinReuseIdentifier";

@interface PLCMapViewController () <MKMapViewDelegate, PLCPlaceStoreDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, readonly) PLCPlaceStore *placeStore;
@property (nonatomic, weak) PLCPinAnnotationView *selectedAnnotationView;

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
        annotationView = pinAnnotation;
        annotationView.draggable = YES;
        annotationView.canShowCallout = NO;
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

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (self.selectedAnnotationView && view != self.selectedAnnotationView) {
        [self.mapView deselectAnnotation:self.selectedAnnotationView.annotation animated:YES];
    }
    // we want to scroll the map such that the annotation view is centered horizontally and 20px above the bottom of the screen.
    // horizontally, this is easy - we're scrolling to the same x-coordinate as the tapped annotation.
    // all that we have to do is figure out the y-coordinate we need to scroll to.
    // step 1 is to figure out the CGPoint that has been tapped
    CGFloat bottomPadding = 50;
    CGFloat animationDuration = 0.1f;
    CGPoint annotationPoint = [self.mapView convertCoordinate:view.annotation.coordinate toPointToView:self.mapView];
    // next, we want to find a point that is (height / 2) - bottomPadding pixels above this point.
    CGFloat deltaY = floorf(CGRectGetHeight(self.mapView.frame)) / 2 - bottomPadding;
    CGPoint destinationPoint = CGPointMake(annotationPoint.x, annotationPoint.y - deltaY);
    // next, convert this point back to map coordinates to get the center of the MKCoordinateRegion we wnat to scroll the map to.
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:destinationPoint toCoordinateFromView:self.mapView];
    // finally, build an MKCoordinateRegion based off of this coordinate and scroll to it.
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, self.mapView.region.span);
    [UIView animateWithDuration:animationDuration animations:^{
        [self.mapView setRegion:region];
    } completion:^(BOOL finished) {
        self.selectedAnnotationView = (PLCPinAnnotationView *)view;
    }];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    if (self.selectedAnnotationView) {
        [self.mapView deselectAnnotation:self.selectedAnnotationView.annotation animated:YES];
        self.selectedAnnotationView = nil;
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

@end
