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

static NSString * const PLCMapPinReuseIdentifier = @"PLCMapPinReuseIdentifier";

@interface PLCMapViewController () <MKMapViewDelegate, PLCPlaceStoreDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, readonly) PLCPlaceStore *placeStore;

@end

@implementation PLCMapViewController

@synthesize placeStore = _placeStore;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.mapView addAnnotations:self.placeStore.allPlaces];
    [self.mapView addGestureRecognizer:[self addPlaceGestureRecognizer]];
}

#pragma mark -
#pragma mark Map view delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:PLCMapPinReuseIdentifier];
    if (!annotationView) {
        MKPinAnnotationView *pinAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PLCMapPinReuseIdentifier];
        pinAnnotation.animatesDrop = YES;
        annotationView = pinAnnotation;
        annotationView.draggable = YES;
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

#pragma mark -
#pragma mark Place Store Delegate
- (void)placeStore:(PLCPlaceStore *)store
    didInsertPlace:(PLCPlace *)place {
    [self.mapView addAnnotation:place];
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
