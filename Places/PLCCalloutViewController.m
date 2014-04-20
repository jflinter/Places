//
//  PLCCalloutViewController.m
//  Places
//
//  Created by Jack Flintermann on 4/19/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCCalloutViewController.h"
#import "PLCCalloutView.h"
#import "PLCShowPlaceViewController.h"
#import "PLCEditPlaceViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface PLCCalloutViewController()
@end

@implementation PLCCalloutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.containerView.layer.cornerRadius = self.calloutView.cornerRadius;
    self.containerView.layer.masksToBounds = YES;
    self.bottomSpacingConstraint.constant = self.calloutView.arrowHeight;

}

- (UIViewController *)showPlaceViewController {
    return [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PLCShowPlaceViewController class])];
}

- (UIViewController *)editPlaceViewController {
    return [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PLCEditPlaceViewController class])];
}

- (PLCCalloutView *)calloutView {
    return (PLCCalloutView *)self.view;
}


@end
