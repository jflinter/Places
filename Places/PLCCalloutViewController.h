//
//  PLCCalloutViewController.h
//  Places
//
//  Created by Jack Flintermann on 4/19/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLCPlace;

@interface PLCCalloutViewController : UIViewController

@property (nonatomic) PLCPlace *place;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpacingConstraint;

@end
