//
//  PLCPinAnnotationView.m
//  Places
//
//  Created by Jack Flintermann on 4/18/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPinAnnotationView.h"

const CGFloat PLCPinAnnotationViewDropDuration = 0.385945f;

@interface PLCPinAnnotationView()
@property(nonatomic, readwrite, assign, getter = isAnimating) BOOL animating;
@end

@implementation PLCPinAnnotationView

@synthesize animating = _animating;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation
         reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        _animating = YES;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    BOOL pointInside = CGRectContainsPoint(self.bounds, point);
    for (UIView *subview in self.subviews) {
        pointInside = pointInside || CGRectContainsPoint(subview.frame, point);
    }
    return pointInside;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.pinColor = selected ? MKPinAnnotationColorGreen : MKPinAnnotationColorRed;
}

- (void)animationDidStop:(CAAnimation *)anim
                finished:(BOOL)flag {
    [super animationDidStop:anim finished:flag];
    self.animating = NO;
}

@end
