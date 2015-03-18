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
#import "PLCPlaceStore.h"
#import "PLCMap.h"
#import "PLCSelectedMapCache.h"
#import "PLCPlaceListTableViewController.h"
#import "PLCSelectedMapViewModel.h"
#import "PLCPinAnnotationView.h"
#import "PLCCalloutViewController.h"
#import <TUSafariActivity/TUSafariActivity.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PLCMapControlsViewController () <UIViewControllerTransitioningDelegate>
@property (nonatomic, weak) PLCMapViewController *mapViewController;
@property (nonatomic) BOOL chromeHidden;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *placeListContainerView;
@property (weak, nonatomic) PLCPlaceListTableViewController *placeListController;
@property (nonatomic) PLCSelectedMapViewModel *viewModel;
@property (nonatomic) BOOL placeListVisible;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *arrowItem;
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
    [self.view sendSubviewToBack:self.mapViewController.view];

    self.toolbarBottomConstraint.constant = 0;
    
    [RACObserve([PLCSelectedMapCache sharedInstance], selectedMap) subscribeNext:^(PLCMap *map) {
        self.title = map.name;
        self.viewModel = [[PLCSelectedMapViewModel alloc] initWithMap:map];
    }];
    
    RAC(self.placeListController, viewModel) = RACObserve(self, viewModel);
    RAC(self.mapViewController, viewModel) = RACObserve(self, viewModel);
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:PLCPlaceStoreWillAddPlaceNotification object:nil]
      takeUntil:[self rac_willDeallocSignal]]
     subscribeNext:^(__unused id x) {
         [self setChromeHidden:YES animated:YES];
     }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil]
      takeUntil:[self rac_willDeallocSignal]]
     subscribeNext:^(__unused id x) {
         [self setChromeHidden:YES animated:YES];
     }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardDidHideNotification object:nil]
      takeUntil:[self rac_willDeallocSignal]]
     subscribeNext:^(__unused id x) {
        [self setChromeHidden:NO animated:YES];
     }];
    
    self.placeListContainerView.clipsToBounds = YES;
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

- (void)setChromeHidden:(BOOL)chromeHidden animated:(__unused BOOL)animated {
    if (_chromeHidden != chromeHidden) {
        _chromeHidden = chromeHidden;
        if (chromeHidden) {
            self.toolbarBottomConstraint.constant = -self.toolbar.frame.size.height;
        } else if (self.placeListVisible) {
            self.toolbarBottomConstraint.constant = self.placeListContainerView.frame.size.height;
        } else {
            self.toolbarBottomConstraint.constant = 0;
        }
        [UIView animateWithDuration:(animated * 0.3) delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
        if (animated) {
            [[UIApplication sharedApplication] setStatusBarHidden:chromeHidden withAnimation:UIStatusBarAnimationSlide];
        } else {
            [[UIApplication sharedApplication] setStatusBarHidden:chromeHidden];
        }
        [self.navigationController setNavigationBarHidden:chromeHidden animated:animated];
    }
}

- (IBAction)showPlaceList:(__unused UIBarButtonItem *)sender {
    [self setPlaceListVisible:!self.placeListVisible animated:YES];
}

- (void)setPlaceListVisible:(BOOL)placeListVisible {
    [self setPlaceListVisible:placeListVisible animated:NO];
}

- (void)setPlaceListVisible:(BOOL)placeListVisible animated:(BOOL)animated {
    _placeListVisible = placeListVisible;
    UIView *view = [self.arrowItem valueForKey:@"view"];
    self.toolbarBottomConstraint.constant = self.placeListVisible ? self.placeListContainerView.frame.size.height : 0;
    [UIView animateWithDuration:(animated * 0.25) delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:0 animations:^{
        [self.view layoutIfNeeded];
        if (self.placeListVisible) {
            view.transform = CGAffineTransformMakeRotation(M_PI*.999);
        } else {
            view.transform = CGAffineTransformIdentity;
        }
    } completion:nil];
}

- (IBAction)showMapSelection:(__unused id)sender {
    if (self.placeListVisible) {
        [self setPlaceListVisible:NO animated:YES];
    }
    UINavigationController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PLCMapSelectionNavigationController"];
    PLCMapSelectionTableViewController *mapSelectionController = (PLCMapSelectionTableViewController *)controller.visibleViewController;
    mapSelectionController.maps = [[PLCMapStore allMaps] mutableCopy];
    controller.modalPresentationStyle = UIModalPresentationCustom;
    controller.transitioningDelegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}


- (IBAction)showLocation:(__unused id)sender {
    [self.mapViewController panToLocation:self.viewModel.currentLocation animated:YES];
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

- (IBAction)addPlace:(__unused id)sender {
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
        [[UIActivityViewController alloc] initWithActivityItems:@[[[PLCSelectedMapCache sharedInstance].selectedMap shareURL]]
                                          applicationActivities:@[[TUSafariActivity new]]];
    // exclude the airdrop action because it's incredibly fucking slow and noone uses it
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAirDrop];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        activityViewController.popoverPresentationController.barButtonItem = sender;
    }
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(__unused id)sender {
    if ([segue.identifier isEqualToString:@"PLCMapControlsEmbedPlaceListSegue"]) {
        self.placeListController = segue.destinationViewController;
    }
}

@end
