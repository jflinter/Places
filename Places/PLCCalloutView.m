//
//  PLCCalloutView.m
//  Places
//
//  Created by Jack Flintermann on 4/19/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCCalloutView.h"

@implementation PLCCalloutView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void) sharedInit {
    self.backgroundColor = [UIColor clearColor];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGFloat arrowHeight = 15.0f;
    CGFloat arrowEdge = arrowHeight * (float)M_SQRT2;
    UIColor *color = [UIColor whiteColor];
    CGRect backgroundRect = CGRectInset(self.bounds, 0, arrowHeight/2);
    backgroundRect.origin.y = 0;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:backgroundRect cornerRadius:10];
    CGRect arrowRect = CGRectMake(-arrowEdge / 2, -arrowEdge / 2, arrowEdge, arrowEdge);
    UIBezierPath *arrowPath = [UIBezierPath bezierPathWithRoundedRect:arrowRect byRoundingCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(2, 2)];
    [arrowPath applyTransform:CGAffineTransformMakeRotation((float)-M_PI_4)];
    [color setFill];
    [path fill];
    CGContextRef aRef = UIGraphicsGetCurrentContext();
    CGContextSaveGState(aRef);
    CGContextTranslateCTM(aRef, backgroundRect.size.width/2, backgroundRect.size.height);
    [arrowPath fill];
    CGContextRestoreGState(aRef);
    [super drawRect:rect];
}


@end
