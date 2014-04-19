//
//  PLCCalloutViewController.h
//  Places
//
//  Created by Jack Flintermann on 4/19/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLCCalloutView;

@interface PLCCalloutViewController : UIViewController
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpacingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpacingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftSpacingConstraint;
@property (weak, nonatomic) IBOutlet PLCCalloutView *calloutView;

@end
