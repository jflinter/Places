//
//  PLCPinAnnotationView.m
//  Places
//
//  Created by Jack Flintermann on 4/18/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPinAnnotationView.h"
#import "PLCCalloutView.h"

@implementation PLCPinAnnotationView

- (BOOL)pointInside:(CGPoint)point withEvent:(__unused UIEvent*)event
{
    BOOL pointInside = CGRectContainsPoint(self.bounds, point);
    for (UIView *subview in self.subviews) {
        pointInside = pointInside || CGRectContainsPoint(subview.frame, point);
    }
    return pointInside;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.pinColor = selected ? MKPinAnnotationColorGreen : MKPinAnnotationColorRed;
}

// measured by subclassing animationDidStart:
+ (NSTimeInterval)pinDropAnimationDuration {
    return 0.42322476003637666f;
}

@end
