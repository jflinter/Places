//
//  PLCTemplateButton.m
//  Places
//
//  Created by Jack Flintermann on 5/1/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCTemplateButton.h"

@implementation PLCTemplateButton

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSArray *states = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateSelected)];
        for (NSNumber *number in states) {
            UIControlState state = [number unsignedIntegerValue];
            UIImage *image = [self imageForState:state];
            if (image) {
                [self setImage:image forState:state];
            }
        }
    }
    return self;
}

- (void)setImage:(UIImage *)image
        forState:(UIControlState)state {
    [super setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:state];
}

@end
