//
//  PLCMapView.m
//  Places
//
//  Created by Jack Flintermann on 4/19/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCMapView.h"
#import "PLCCalloutView.h"

@implementation PLCMapView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    if (self.activeCalloutView) {
        CGPoint point = [touch locationInView:self.activeCalloutView];
        if ([self.activeCalloutView pointInside:point withEvent:nil]) {
            return NO;
        }
    }
    return YES;
}

- (void)removeAnnotation:(id<MKAnnotation>)annotation
                animated:(BOOL)animated {
    MKAnnotationView *view = [self viewForAnnotation:annotation];
    [UIView animateWithDuration:0.3f animations:^{
        view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [super removeAnnotation:annotation];
        view.alpha = 1.0f;
    }];
}

@end
