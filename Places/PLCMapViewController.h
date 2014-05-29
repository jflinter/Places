//
//  PLCMapViewController.h
//  Places
//
//  Created by Cameron Spickert on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PLCMapView;
@interface PLCMapViewController : UIViewController;
@property (nonatomic, weak, readonly) IBOutlet PLCMapView *mapView;
- (IBAction)showLocation:(id)sender;
- (IBAction)dropPin:(id)sender;

@end
