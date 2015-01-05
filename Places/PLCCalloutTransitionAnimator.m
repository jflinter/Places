//
//  PLCCalloutTransitionAnimator.m
//  Places
//
//  Created by Cameron Spickert on 4/26/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCCalloutTransitionAnimator.h"
#import "PLCCalloutViewController.h"
#import "PLCCalloutTransitionContext.h"

@implementation PLCCalloutTransitionAnimator

- (NSTimeInterval)transitionDuration:(__unused id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.35;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    [self animateTransition:transitionContext completion:nil];
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
               completion:(void (^)())completion {
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
    
    CGSize const calloutViewSize = [PLCCalloutViewController calloutSize];
    CGPoint const calloutPresentationOrigin = CGPointMake(CGRectGetMidX(annotationView.bounds) + annotationView.calloutOffset.x, CGRectGetMinY(annotationView.bounds));
    
    calloutView.frame = CGRectMake(calloutPresentationOrigin.x - calloutViewSize.width / 2.0f, calloutPresentationOrigin.y - calloutViewSize.height, calloutViewSize.width, calloutViewSize.height);
    
    if (isPresenting) {
        calloutView.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
        
        [annotationView addSubview:calloutView];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:0.8f
              initialSpringVelocity:0.0f
                            options:0
                         animations:^{
                             calloutView.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:finished];
                             if (completion) {
                                 completion();
                             }
                         }];
    } else {
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             calloutView.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
                         }
                         completion:^(BOOL finished) {
                             [calloutView removeFromSuperview];
                             [transitionContext completeTransition:finished];
                             if (completion) {
                                 completion();
                             }
                         }];
    }
}

@end
