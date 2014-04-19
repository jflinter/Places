//
//  PLCCalloutViewController.m
//  Places
//
//  Created by Jack Flintermann on 4/19/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCCalloutViewController.h"
#import "PLCCalloutView.h"

@implementation PLCCalloutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    PLCCalloutView *calloutView = (PLCCalloutView *)self.view;
    self.topSpacingConstraint.constant = calloutView.cornerRadius;
    self.leftSpacingConstraint.constant = calloutView.cornerRadius;
    self.bottomSpacingConstraint.constant = calloutView.cornerRadius + calloutView.arrowHeight;
}

@end
