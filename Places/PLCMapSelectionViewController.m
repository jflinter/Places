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

- (void)setupGestureRecognizer {
    if (self.gestureRecognizer) {
        [self.view removeGestureRecognizer:self.gestureRecognizer];
        self.gestureRecognizer = nil;
    }
    self.gestureRecognizer = nil;
    if ([self.transitioningDelegate isKindOfClass:[PLCMapSelectionTransitionAnimator class]]) {
        PLCMapSelectionTransitionAnimator *animator = (PLCMapSelectionTransitionAnimator *)self.transitioningDelegate;
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:animator action:@selector(panned:)];
        recognizer.delegate = [self tableViewController];
        self.gestureRecognizer = recognizer;
        [self.view addGestureRecognizer:recognizer];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollEnabled = scrollEnabled;
    [self tableViewController].tableView.scrollEnabled = scrollEnabled;
}

- (PLCMapSelectionTableViewController *) tableViewController {
    UINavigationController *navController = [self.childViewControllers firstObject];
    PLCMapSelectionTableViewController *controller = [navController.viewControllers firstObject];
    if ([controller isKindOfClass:[PLCMapSelectionTableViewController class]]) {
        return controller;
    }
    return nil;
}

@end