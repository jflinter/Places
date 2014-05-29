//
//  PLCMapSelectionTransitionAnimator.h
//  Places
//
//  Created by Jack Flintermann on 5/23/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLCMapSelectionTransitionAnimator : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIViewControllerInteractiveTransitioning>
@property(nonatomic, readwrite, assign)BOOL presenting;
@property(nonatomic, readwrite, assign)BOOL interactive;
- (id)initWithParentViewController:(UIViewController *)parentViewController;
- (void)panned:(UIPanGestureRecognizer *)recognizer;
@end
