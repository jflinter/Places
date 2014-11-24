//
//  PLCCalloutView.m
//  Places
//
//  Created by Jack Flintermann on 4/19/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCCalloutView.h"

@interface PLCCalloutView ()

@end

@implementation PLCCalloutView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    self.backgroundColor = [UIColor clearColor];
    self.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
    self.layer.masksToBounds = NO;
    self.layer.cornerRadius = self.cornerRadius; // if you like rounded corners
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.3f;

    UIInterpolatingMotionEffect *verticalMotionEffect =
        [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"layer.shadowOffset" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = [NSValue valueWithCGSize:CGSizeMake(0, 10)];
    verticalMotionEffect.maximumRelativeValue = [NSValue valueWithCGSize:CGSizeMake(0, -10)];

    UIInterpolatingMotionEffect *horizontalMotionEffect =
        [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"layer.shadowOffset" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = [NSValue valueWithCGSize:CGSizeMake(-10, 0)];
    horizontalMotionEffect.maximumRelativeValue = [NSValue valueWithCGSize:CGSizeMake(10, 0)];

    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];

    [self addMotionEffect:group];
}

- (void)drawRect:(CGRect)rect {
    CGFloat arrowEdge = self.arrowHeight * (float)M_SQRT2;
    UIColor *color = [UIColor whiteColor];
    CGRect backgroundRect = CGRectInset(self.bounds, 0, self.arrowHeight / 2);
    backgroundRect.origin.y = 0;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:backgroundRect cornerRadius:self.cornerRadius];
    CGRect arrowRect = CGRectMake(-arrowEdge / 2, -arrowEdge / 2, arrowEdge, arrowEdge);
    UIBezierPath *arrowPath = [UIBezierPath bezierPathWithRoundedRect:arrowRect byRoundingCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(2, 2)];
    [arrowPath applyTransform:CGAffineTransformMakeRotation((float)-M_PI_4)];
    [color setFill];
    [path fill];
    CGContextRef aRef = UIGraphicsGetCurrentContext();
    CGContextSaveGState(aRef);
    CGContextTranslateCTM(aRef, backgroundRect.size.width / 2, backgroundRect.size.height);
    [arrowPath fill];
    CGContextRestoreGState(aRef);
    [super drawRect:rect];
}

- (CGFloat)arrowHeight {
    return 10.0f;
}

- (CGFloat)cornerRadius {
    return 10.0f;
}

@end
