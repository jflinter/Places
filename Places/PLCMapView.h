//
//  PLCMapView.h
//  Places
//
//  Created by Jack Flintermann on 4/19/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <MapKit/MapKit.h>

@class PLCMapView;

@protocol PLCMapViewDelegate <MKMapViewDelegate>
@required

- (NSArray *)presentedCalloutViewControllersForMapView:(PLCMapView *)mapView;

@end

@interface PLCMapView : MKMapView <UIGestureRecognizerDelegate>

@property (nonatomic, assign) id<PLCMapViewDelegate> delegate;

- (void) resetScale;

@end
