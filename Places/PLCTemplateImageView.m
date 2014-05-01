//
//  PLCTemplateImageView.m
//  Places
//
//  Created by Jack Flintermann on 5/1/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCTemplateImageView.h"

@implementation PLCTemplateImageView

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setImage:self.image];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    [super setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
}

@end
