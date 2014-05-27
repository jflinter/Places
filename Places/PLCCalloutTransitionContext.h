//
//  PLCCalloutTransitionContext.h
//  Places
//
//  Created by Cameron Spickert on 4/27/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PLCCalloutTransitionContextOperation) {
    PLCCalloutTransitionContextOperationInvalid = 0,
    PLCCalloutTransitionContextOperationPresent,
    PLCCalloutTransitionContextOperationDismiss
};

@class PLCMapViewController;
@class PLCCalloutViewController;

@interface PLCCalloutTransitionContext : NSObject <UIViewControllerContextTransitioning>

- (instancetype)initWithOperation:(PLCCalloutTransitionContextOperation)operation;

@property (nonatomic, readonly) PLCCalloutTransitionContextOperation operation;
@property (nonatomic) PLCMapViewController *mapViewController;
@property (nonatomic) PLCCalloutViewController *calloutViewController;
@property (nonatomic) UIView *containerView;
@property (nonatomic) UIView *menuControl;

@end
