//
//  PLCBlurredModalPresentationController.m
//  Places
//
//  Created by Jack Flintermann on 9/21/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCBlurredModalPresentationController.h"

@interface PLCBlurredModalPresentationController ()
@property (nonatomic, weak) UIVisualEffectView *blurView;
@property (nonatomic, weak) UIView *blurOverlayView;
@end

@implementation PLCBlurredModalPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        _edgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    }
    return self;
}

- (void)presentationTransitionWillBegin {
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    blurView.frame = self.containerView.bounds;
    self.blurView = blurView;
    UIView *snapshot = [self.presentingViewController.view snapshotViewAfterScreenUpdates:NO];
    self.blurOverlayView = snapshot;
    [self.containerView addSubview:self.blurView];
    [self.containerView addSubview:snapshot];
    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(__unused id<UIViewControllerTransitionCoordinatorContext> context) {
        self.blurOverlayView.alpha = 0.0f;
    } completion:^(__unused id<UIViewControllerTransitionCoordinatorContext> context){}];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    if (!completed) {
        [self.blurView removeFromSuperview];
        [self.blurOverlayView removeFromSuperview];
    }
}

- (void)dismissalTransitionWillBegin {
    [self.blurOverlayView removeFromSuperview];
    UIView *snapshot = [self.presentingViewController.view snapshotViewAfterScreenUpdates:NO];
    snapshot.alpha = 0.0f;
    self.blurOverlayView = snapshot;
    [self.containerView insertSubview:snapshot aboveSubview:self.blurView];
    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(__unused id<UIViewControllerTransitionCoordinatorContext> context) {
        self.blurOverlayView.alpha = 1.0f;
    } completion:nil];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [self.blurView removeFromSuperview];
        [self.blurOverlayView removeFromSuperview];
    }
}

- (CGRect)frameOfPresentedViewInContainerView {
    CGRect rect = self.containerView.bounds;
    rect.origin.x += self.edgeInsets.left;
    rect.size.width -= self.edgeInsets.left;
    rect.size.width -= self.edgeInsets.right;
    rect.origin.y += self.edgeInsets.top;
    rect.size.height -= self.edgeInsets.top;
    rect.size.height -= self.edgeInsets.bottom;
    return rect;
}

@end
