//
//  PLCCalloutTransitionAnimator.m
//  Places
//
//  Created by Cameron Spickert on 4/26/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCCalloutTransitionAnimator.h"
#import "PLCCalloutViewController.h"

@implementation PLCCalloutTransitionAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.35;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    MKAnnotationView *const annotationView = (MKAnnotationView *)[transitionContext containerView];
    NSParameterAssert([annotationView isKindOfClass:[MKAnnotationView class]]);

    UIViewController *srcViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *dstViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    BOOL isPresenting;
    PLCCalloutViewController *calloutViewController;

    if ([dstViewController isKindOfClass:[PLCCalloutViewController class]]) {
        isPresenting = YES;
        calloutViewController = (PLCCalloutViewController *)dstViewController;
    } else if ([srcViewController isKindOfClass:[PLCCalloutViewController class]]) {
        isPresenting = NO;
        calloutViewController = (PLCCalloutViewController *)srcViewController;
    } else {
        isPresenting = NO;
        calloutViewController = nil;
        NSAssert1(NO, @"Expected instance of %@", NSStringFromClass([PLCCalloutViewController class]));
    }

    UIView *const calloutView = calloutViewController.view;

    CGSize const calloutViewSize = CGSizeMake(300.0f, 300.0f);
    CGPoint const calloutPresentationOrigin = CGPointMake(CGRectGetMidX(annotationView.bounds) + annotationView.calloutOffset.x, CGRectGetMinY(annotationView.bounds));

    calloutView.frame = CGRectMake(calloutPresentationOrigin.x - calloutViewSize.width / 2.0f, calloutPresentationOrigin.y - calloutViewSize.height, calloutViewSize.width, calloutViewSize.height);

    if (isPresenting) {
        calloutView.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
        calloutView.alpha = 0.0f;

        [annotationView addSubview:calloutView];

        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:0.8f
              initialSpringVelocity:0.0f
                            options:0
                         animations:^{
                             calloutView.alpha = 1.0f;
                             calloutView.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:finished];
                         }];
    } else {
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             calloutView.alpha = 0.0f;
                             calloutView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:finished];
                         }];
    }
}

@end
