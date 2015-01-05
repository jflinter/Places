//
//  PLCCalloutTransitionContext.m
//  Places
//
//  Created by Cameron Spickert on 4/27/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCCalloutTransitionContext.h"

@interface PLCCalloutTransitionContext ()

@property (nonatomic) PLCCalloutTransitionContextOperation operation;

@end

@implementation PLCCalloutTransitionContext

- (CGAffineTransform)targetTransform {
    return CGAffineTransformIdentity;
}

- (instancetype)initWithOperation:(PLCCalloutTransitionContextOperation)operation
{
    if ((self = [super init])) {
        _operation = operation;
    }
    return self;
}

- (BOOL)isAnimated
{
    return YES;
}

- (BOOL)isInteractive
{
    return NO;
}

- (BOOL)transitionWasCancelled
{
    return NO;
}

- (UIModalPresentationStyle)presentationStyle
{
    return UIModalPresentationCustom;
}

- (void)updateInteractiveTransition:(__unused CGFloat)percentComplete
{
    return;
}

- (void)finishInteractiveTransition
{
    return;
}

- (void)cancelInteractiveTransition
{
    return;
}

- (void)completeTransition:(__unused BOOL)didComplete
{
    return;
}

- (UIViewController *)viewControllerForKey:(NSString *)key
{
    NSDictionary *viewControllers = nil;
    if (self.operation == PLCCalloutTransitionContextOperationPresent) {
        viewControllers = @{
                            UITransitionContextFromViewControllerKey : self.mapViewController,
                            UITransitionContextToViewControllerKey : self.calloutViewController };
    } else if (self.operation == PLCCalloutTransitionContextOperationDismiss) {
        viewControllers = @{
                            UITransitionContextFromViewControllerKey : self.calloutViewController,
                            UITransitionContextToViewControllerKey : self.mapViewController };
    }
    return viewControllers[key];
}

- (UIView *)viewForKey:(NSString *)key {
    return [[self viewControllerForKey:key] view];
}

- (CGRect)initialFrameForViewController:(__unused UIViewController *)vc
{
    return CGRectNull;
}

- (CGRect)finalFrameForViewController:(__unused UIViewController *)vc
{
    return CGRectNull;
}

@end
