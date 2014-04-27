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
    self.layer.anchorPoint = CGPointMake(0.5, 1.0);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGFloat arrowEdge = self.arrowHeight * (float)M_SQRT2;
    UIColor *color = [UIColor whiteColor];
    CGRect backgroundRect = CGRectInset(self.bounds, 0, self.arrowHeight/2);
    backgroundRect.origin.y = 0;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:backgroundRect cornerRadius:self.cornerRadius];
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

- (CGFloat)arrowHeight {
    return 15.0f;
}

- (CGFloat) cornerRadius {
    return 10.0f;
}

- (void) showInView:(UIView *)view {
    // Center the callout view above the annotation view.
    CGFloat animationDuration = 0.5f;
    CGRect calloutViewFrame = self.frame;
    calloutViewFrame.size = CGSizeMake(300, 300);
    calloutViewFrame.origin.x = ((CGRectGetWidth(view.frame)/2) - CGRectGetWidth(calloutViewFrame)) / 2;
    calloutViewFrame.origin.y = - CGRectGetHeight(calloutViewFrame);
    self.frame = calloutViewFrame;
    self.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
    self.alpha = 0.0f;
    [view addSubview:self];
    [UIView animateWithDuration:animationDuration
                          delay:0
         usingSpringWithDamping:0.8f
          initialSpringVelocity:0.0f
                        options:0
                     animations:^{
                         self.alpha = 1.0f;
                         self.transform = CGAffineTransformIdentity;
                     }
                     completion:nil];

}

- (void)hide {
    CGFloat animationDuration = 0.5f;
    [UIView animateWithDuration:animationDuration
                          delay:0
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.alpha = 0.0f;
                         self.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
                     }
                     completion:^(BOOL finished) {
                         self.alpha = 1.0f;
                         self.transform = CGAffineTransformIdentity;
                         [self removeFromSuperview];
                     }];
}

@end
