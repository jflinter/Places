//
//  PLCMapSelectionTransitionAnimator.m
//  Places
//
//  Created by Jack Flintermann on 5/23/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCMapSelectionTransitionAnimator.h"
#import "UIView+SnapshotImage.h"
#import "UIImage+ImageEffects.h"
#import "PLCMapViewController.h"
#import "PLCMapSelectionViewController.h"

@interface PLCMapSelectionTransitionAnimator()
@property(nonatomic)UIViewController *parentViewController;
@property(nonatomic)id <UIViewControllerContextTransitioning> transitionContext;
@property(nonatomic)CGRect originalDismissalRect;
@property(nonatomic)CGPoint originalDismissalPoint;
@end

@implementation PLCMapSelectionTransitionAnimator

- (id)initWithParentViewController:(UIViewController *)parentViewController {
    self = [super init];
    if (self) {
        _parentViewController = parentViewController;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.4f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.interactive) {
        return;
    }
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    fromViewController.view.userInteractionEnabled = NO;
    
    if (self.presenting) {
        PLCMapSelectionViewController *controller = (PLCMapSelectionViewController *)toViewController;
        controller.view.frame = fromViewController.view.frame;
        controller.containerView.frame = ({
            CGRect rect = controller.containerView.frame;
            rect.origin.y = CGRectGetMaxY(rect);
            rect;
        });
        id viewToBlur = fromViewController.view;
        if ([fromViewController isKindOfClass:[UINavigationController class]]) {
            UIViewController *viewController = [[(UINavigationController *)fromViewController viewControllers] lastObject];
            if ([viewController isKindOfClass:[PLCMapViewController class]]) {
                viewToBlur = [(PLCMapViewController *)viewController mapView];
            }
        }
        UIImage *blurredSnapshot = [[viewToBlur snapshotImage] applySubtleEffect];
        controller.backgroundImageView.alpha = 0;
        controller.backgroundImageView.image = blurredSnapshot;
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:0.5f options:0 animations:^{
            controller.containerView.frame = ({
                CGRect rect = controller.containerView.frame;
                rect.origin.y = 0;
                rect;
            });
            controller.backgroundImageView.alpha = 1.0f;
            
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        PLCMapSelectionViewController *controller = (PLCMapSelectionViewController *)fromViewController;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1.0f initialSpringVelocity:-5.0f options:0 animations:^{
            controller.backgroundImageView.alpha = 0;
            fromViewController.view.frame = ({
                CGRect rect = fromViewController.view.frame;
                rect.origin.y = CGRectGetMaxY(rect) + CGRectGetMinY(rect) * 2;
                rect;
            });
        } completion:^(BOOL finished) {
            toViewController.view.userInteractionEnabled = YES;
            [transitionContext completeTransition:YES];
        }];
    }
}

- (void)panned:(UIPanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:recognizer.view];
    CGPoint velocity = [recognizer velocityInView:recognizer.view];
    // Determine our ratio between the left edge and the right edge. This means our dismissal will go from 1...0.
    CGFloat difference = location.y - self.originalDismissalPoint.y;
    CGFloat ratio = difference / CGRectGetHeight(self.parentViewController.view.bounds);
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // We're being invoked via a gesture recognizer – we are necessarily interactive
        self.interactive = YES;
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        self.originalDismissalPoint = location;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self updateInteractiveTransition:ratio];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        // Depending on our state and the velocity, determine whether to cancel or complete the transition.
        if (velocity.y > 0 && ratio > 0.3) {
            [self finishInteractiveTransition];
        }
        else {
            [self cancelInteractiveTransition];
        }
    }
}

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    
    PLCMapSelectionViewController *fromViewController = (PLCMapSelectionViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    toViewController.view.frame = [[transitionContext containerView] bounds];
    
    [transitionContext.containerView addSubview:toViewController.view];
    [transitionContext.containerView addSubview:fromViewController.view];
    self.originalDismissalRect = fromViewController.containerView.frame;
    fromViewController.scrollEnabled = NO;
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    PLCMapSelectionViewController *fromViewController = (PLCMapSelectionViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CGRect rect = self.originalDismissalRect;
    rect.origin.y += (percentComplete * [[transitionContext containerView] bounds].size.height);
    // Presenting goes from 0...1 and dismissing goes from 1...0
    fromViewController.containerView.frame = rect;
    fromViewController.backgroundImageView.alpha = 1.0f - percentComplete;
}

- (void)finishInteractiveTransition {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    PLCMapSelectionViewController *fromViewController = (PLCMapSelectionViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect frame = self.originalDismissalRect;
    frame.origin.y = CGRectGetHeight(self.originalDismissalRect);
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        fromViewController.containerView.frame = frame;
        fromViewController.backgroundImageView.alpha = 0;
    } completion:^(BOOL finished) {
        toViewController.view.userInteractionEnabled = YES;
        [transitionContext completeTransition:YES];
    }];
}

- (void)cancelInteractiveTransition {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    PLCMapSelectionViewController *fromViewController = (PLCMapSelectionViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [UIView animateWithDuration:1.0f delay:0 usingSpringWithDamping:0.5f initialSpringVelocity:0.2f options:0 animations:^{
        fromViewController.containerView.frame = self.originalDismissalRect;
        fromViewController.backgroundImageView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        fromViewController.scrollEnabled = YES;
        [transitionContext completeTransition:NO];
    }];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.presenting = NO;
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return self.interactive ? self : nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return self.interactive ? self : nil;
}

@end
