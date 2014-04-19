//
//  PLCMapView.m
//  Places
//
//  Created by Jack Flintermann on 4/19/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCMapView.h"

@implementation PLCMapView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    if (self.activeAnnotationView) {
        CGPoint point = [touch locationInView:self.activeAnnotationView];
        if ([self.activeAnnotationView pointInside:point withEvent:nil]) {
            return NO;
        }
    }
    return YES;
}

@end
