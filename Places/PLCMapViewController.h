//
//  PLCMapViewController.h
//  Places
//
//  Created by Cameron Spickert on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLCMapView, PLCPlace;
@interface PLCMapViewController : UIViewController;
@property (nonatomic, weak, readonly) PLCMapView *mapView;

@property (nonatomic) PLCPlace *selectedPlace;

- (void)showLocation:(id)sender;
- (void)dropPin:(id)sender;

@end
