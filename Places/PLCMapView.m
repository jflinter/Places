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

@end
