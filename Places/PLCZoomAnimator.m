//
//  PLCZoomAnimator.m
//  Places
//
//  Created by Jack Flintermann on 11/9/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCZoomAnimator.h"

@implementation PLCZoomAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.presenting) {
        return 0.4f;
    }
    return 0.3f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *container = [transitionContext containerView];
    if (self.presenting) {
        toView.frame = [toViewController.presentationController frameOfPresentedViewInContainerView];
        [container addSubview:toView];
        toView.alpha = 0;
        toView.transform = CGAffineTransformMakeScale(0.3, 0.3);
    } else {
        [container insertSubview:toView belowSubview:fromView];
    }
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
        delay:0
        usingSpringWithDamping:0.8f
        initialSpringVelocity:0
        options:UIViewAnimationOptionAllowUserInteraction
        animations:^{
            if (self.presenting) {
                toView.alpha = 1;
                toView.transform = CGAffineTransformIdentity;
            } else {
                fromView.transform = CGAffineTransformMakeScale(0.3, 0.3);
                fromView.alpha = 0;
            }
        }
        completion:^(BOOL finished) { [transitionContext completeTransition:finished]; }];
}

@end
