//
//  PLCMapSelectionViewController.m
//  Places
//
//  Created by Jack Flintermann on 5/23/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCMapSelectionViewController.h"
#import "PLCMapSelectionTransitionAnimator.h"
#import "PLCMapSelectionTableViewController.h"
#import "PLCPlaceSearchTableViewController.h"

@interface PLCMapSelectionViewController ()
@property(nonatomic, readwrite, weak)UIPanGestureRecognizer *gestureRecognizer;
@end

@implementation PLCMapSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentView.layer.cornerRadius = 5.0f;
}

- (void)setTransitioningDelegate:(id<UIViewControllerTransitioningDelegate>)transitioningDelegate {
    [super setTransitioningDelegate:transitioningDelegate];
    [self setupGestureRecognizer];
}

- (void)addChildViewController:(UIViewController *)childController {
    [super addChildViewController:childController];
    [self setupGestureRecognizer];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if (self.embeddedConfigurationBlock) {
        self.embeddedConfigurationBlock(segue.destinationViewController);
    }
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = segue.destinationViewController;
        PLCMapSelectionTableViewController *tableViewController = [navController.viewControllers firstObject];
        if ([tableViewController isKindOfClass:[PLCMapSelectionTableViewController class]]) {
            self.scrollController = tableViewController;
        }
    }
    if ([segue.destinationViewController isKindOfClass:[PLCPlaceSearchTableViewController class]]) {
        PLCPlaceSearchTableViewController *controller = segue.destinationViewController;
        if ([controller isKindOfClass:[PLCPlaceSearchTableViewController class]]) {
            self.scrollController = controller;
        }
    }
}

- (void)setupGestureRecognizer {
    if (self.gestureRecognizer) {
        [self.view removeGestureRecognizer:self.gestureRecognizer];
        self.gestureRecognizer = nil;
    }
    if ([self.transitioningDelegate isKindOfClass:[PLCMapSelectionTransitionAnimator class]]) {
        PLCMapSelectionTransitionAnimator *animator = (PLCMapSelectionTransitionAnimator *)self.transitioningDelegate;
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:animator action:@selector(panned:)];
        recognizer.delegate = self.scrollController;
        self.gestureRecognizer = recognizer;
        [self.view addGestureRecognizer:recognizer];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollEnabled = scrollEnabled;
    self.scrollController.scrollView.scrollEnabled = scrollEnabled;
}

@end
