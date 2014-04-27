//
//  PLCCalloutViewController.m
//  Places
//
//  Created by Jack Flintermann on 4/19/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPlace.h"
#import "PLCCalloutView.h"
#import "PLCCalloutViewController.h"
#import "PLCShowPlaceViewController.h"
#import "PLCEditPlaceViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface PLCCalloutViewController() <UINavigationControllerDelegate>

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak, readonly) PLCCalloutView *calloutView;

@end

@implementation PLCCalloutViewController

@dynamic calloutView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.containerView.layer.cornerRadius = self.calloutView.cornerRadius;
    self.containerView.layer.masksToBounds = YES;
    self.bottomSpacingConstraint.constant = self.calloutView.arrowHeight;
}

- (PLCCalloutView *)calloutView
{
    return (PLCCalloutView *)self.view;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PLCCalloutNavigationEmbedSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        navController.delegate = self;
    }
    [super prepareForSegue:segue sender:sender];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    PLCShowPlaceViewController *controller = (PLCShowPlaceViewController *)viewController;
    controller.place = self.place;
}

@end
