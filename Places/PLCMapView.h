//
//  PLCMapView.h
//  Places
//
//  Created by Jack Flintermann on 4/19/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <MapKit/MapKit.h>

@class PLCCalloutView;

@interface PLCMapView : MKMapView<UIGestureRecognizerDelegate>
@property(nonatomic, readwrite, weak)MKAnnotationView *activeAnnotationView;
@property(nonatomic, readwrite, weak)PLCCalloutView *activeCalloutView;
@end
