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

- (instancetype)initWithOperation:(PLCCalloutTransitionContextOperation)operation
{
    if ((self = [super init])) {
        self.operation = operation;
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

- (void)updateInteractiveTransition:(CGFloat)percentComplete
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

- (void)completeTransition:(BOOL)didComplete
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

- (CGRect)initialFrameForViewController:(UIViewController *)vc
{
    return CGRectNull;
}

- (CGRect)finalFrameForViewController:(UIViewController *)vc
{
    return CGRectNull;
}

@end
