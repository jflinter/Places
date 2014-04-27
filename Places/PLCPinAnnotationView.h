//
//  PLCPinAnnotationView.h
//  Places
//
//  Created by Jack Flintermann on 4/18/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <MapKit/MapKit.h>

const extern CGFloat PLCPinAnnotationViewDropDuration;

@interface PLCPinAnnotationView : MKPinAnnotationView
@property(nonatomic, readonly, assign, getter = isAnimating) BOOL animating;
@end
