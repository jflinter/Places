//
//  PLCMapControlsViewController.m
//  Places
//
//  Created by Jack Flintermann on 3/9/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import "PLCMapControlsViewController.h"
#import "PLCMapViewController.h"
#import "PLCPlaceSearchTableViewController.h"
#import "PLCMapSelectionTableViewController.h"
#import "PLCBlurredModalPresentationController.h"
#import "PLCZoomAnimator.h"
#import "PLCMapView.h"
#import "PLCMapStore.h"
#import "PLCMap.h"
#import <TUSafariActivity/TUSafariActivity.h>

@interface PLCMapControlsViewController () <UIViewControllerTransitioningDelegate>
@property (nonatomic, weak) PLCMapViewController *mapViewController;
@property (nonatomic) BOOL chromeHidden;
@end

@implementation PLCMapControlsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PLCMapViewController *mapViewController = [[PLCMapViewController alloc] init];
    _mapViewController = mapViewController;
    [self addChildViewController:mapViewController];
    mapViewController.view.frame = self.view.bounds;
    [self.view addSubview:mapViewController.view];
    [mapViewController didMoveToParentViewController:self];

    UIImage *plusImage = [UIImage imageNamed:@"709-plus-toolbar"];
    self.toolbarItems = @[
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
        [[UIBarButtonItem alloc] initWithImage:plusImage style:UIBarButtonItemStylePlain target:self action:@selector(addPlace:)],
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"723-location-arrow-toolbar"]
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(showLocation:)],
    ];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      self.chromeHidden = YES;
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      [self setChromeHidden:NO animated:YES];
    });
}

- (void)setChromeHidden:(BOOL)chromeHidden {
    [self setChromeHidden:chromeHidden animated:NO];
}

- (void)setChromeHidden:(BOOL)chromeHidden animated:(BOOL)animated {
    if (_chromeHidden != chromeHidden) {
        _chromeHidden = chromeHidden;
        [self.navigationController setToolbarHidden:chromeHidden animated:animated];
        if (animated) {
            [[UIApplication sharedApplication] setStatusBarHidden:chromeHidden withAnimation:UIStatusBarAnimationSlide];
        } else {
            [[UIApplication sharedApplication] setStatusBarHidden:chromeHidden];
        }
        [self.navigationController setNavigationBarHidden:chromeHidden animated:animated];
    }
}

- (IBAction)showMapSelection:(__unused id)sender {
    UINavigationController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PLCMapSelectionNavigationController"];
    controller.modalPresentationStyle = UIModalPresentationCustom;
    controller.transitioningDelegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)showLocation:(id)sender {
    [self.mapViewController showLocation:sender];
}

- (void)beginSearch:(__unused id)sender {
    PLCPlaceSearchTableViewController *tableViewController = [PLCPlaceSearchTableViewController new];
    tableViewController.searchRegion = self.mapViewController.mapView.region;
    tableViewController.transitioningDelegate = self;
    tableViewController.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:tableViewController animated:YES completion:nil];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(__unused UIViewController *)presented
                                                                  presentingController:(__unused UIViewController *)presenting
                                                                      sourceController:(__unused UIViewController *)source {
    PLCZoomAnimator *animator = [PLCZoomAnimator new];
    animator.presenting = YES;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(__unused UIViewController *)dismissed {
    PLCZoomAnimator *animator = [PLCZoomAnimator new];
    animator.presenting = NO;
    return animator;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(__unused UIViewController *)presented
                                                      presentingViewController:(__unused UIViewController *)presenting
                                                          sourceViewController:(__unused UIViewController *)source {
    PLCBlurredModalPresentationController *controller =
        [[PLCBlurredModalPresentationController alloc] initWithPresentedViewController:presented presentingViewController:self];
    if ([presented isKindOfClass:[UINavigationController class]]) {
        controller.edgeInsets = UIEdgeInsetsZero;
    } else {
        controller.edgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    }
    return controller;
}

- (void)addPlace:(__unused id)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Search Nearby Places", nil)
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *action) {
                                                   [self beginSearch:action];
                                                 }]];
    [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Add Current Location", nil)
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *action) {
                                                   [self.mapViewController dropPin:action];
                                                 }]];

    [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)shareMap:(UIBarButtonItem *)sender {
    UIActivityViewController *activityViewController =
        [[UIActivityViewController alloc] initWithActivityItems:@[[[PLCMapStore sharedInstance].selectedMap shareURL]]
                                          applicationActivities:@[[TUSafariActivity new]]];
    // exclude the airdrop action because it's incredibly fucking slow and noone uses it
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAirDrop];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        activityViewController.popoverPresentationController.barButtonItem = sender;
    }
    [self presentViewController:activityViewController animated:YES completion:nil];
}

@end
