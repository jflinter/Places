//
//  PLCMapViewController.h
//  Places
//
//  Created by Cameron Spickert on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLCMapView, PLCPlace, PLCSelectedMapViewModel;
@interface PLCMapViewController : UIViewController;
@property (nonatomic, weak, readonly) PLCMapView *mapView;

@property (nonatomic) PLCSelectedMapViewModel *viewModel;

- (void)dropPin:(id)sender;
- (void)panToLocation:(CLLocation *)location animated:(BOOL)animated;

@end
