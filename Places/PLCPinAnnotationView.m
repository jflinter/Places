//
//  PLCPinAnnotationView.m
//  Places
//
//  Created by Jack Flintermann on 4/18/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPinAnnotationView.h"
#import "PLCCalloutViewController.h"

@interface PLCPinAnnotationView()
@property(nonatomic, readonly) PLCCalloutViewController *calloutViewController;
@end

@implementation PLCPinAnnotationView

@synthesize calloutViewController = _calloutViewController;

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    UIView *calloutView = self.calloutViewController.view;
    return CGRectContainsPoint(self.bounds, point) || CGRectContainsPoint(calloutView.frame, point);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    CGFloat animationDuration = 0.5f;
    self.pinColor = selected ? MKPinAnnotationColorGreen : MKPinAnnotationColorRed;
    // Get the custom callout view.
    UIView *calloutView = self.calloutViewController.view;
    calloutView.layer.anchorPoint = CGPointMake(0.5, 1.0);
    if (selected) {
        // Center the callout view above the annotation view.
        CGRect calloutViewFrame = calloutView.frame;
        calloutViewFrame.size = CGSizeMake(300, 300);
        calloutViewFrame.origin.x = ((CGRectGetWidth(self.frame)/2) - CGRectGetWidth(calloutViewFrame)) / 2;
        calloutViewFrame.origin.y = - CGRectGetHeight(calloutViewFrame);
        calloutView.frame = calloutViewFrame;
        calloutView.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
        calloutView.alpha = 0.0f;
        [self addSubview:calloutView];
        [UIView animateWithDuration:animationDuration
                              delay:0
             usingSpringWithDamping:0.8f
              initialSpringVelocity:0.0f
                            options:0
                         animations:^{
                            calloutView.alpha = 1.0f;
                            calloutView.transform = CGAffineTransformIdentity;
                         }
                         completion:nil];
    } else {
        [UIView animateWithDuration:animationDuration
                              delay:0
             usingSpringWithDamping:1.0f
              initialSpringVelocity:-15.0f
                            options:0
                         animations:^{
                             calloutView.alpha = 0.0f;
                             calloutView.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 calloutView.alpha = 1.0f;
                                 calloutView.transform = CGAffineTransformIdentity;
                                 [calloutView removeFromSuperview];
                             }
                         }];
    }
}

- (PLCCalloutViewController *) calloutViewController {
    if (!_calloutViewController) {
        UIStoryboard *storyboard = [[self.window rootViewController] storyboard];
        _calloutViewController = [storyboard instantiateViewControllerWithIdentifier:@"PLCCalloutViewController"];
    }
    return _calloutViewController;
}

@end
