//
//  PLCFlickrResultCollectionViewCell.m
//  Places
//
//  Created by Jack Flintermann on 9/21/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCFlickrResultCollectionViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface PLCFlickrResultCollectionViewCell()
@property(nonatomic, readwrite, weak)UIImageView *imageView;
@property(nonatomic, weak)UIActivityIndicatorView *activityIndicator;
@end

@implementation PLCFlickrResultCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.cornerRadius = 3.0f;
    imageView.clipsToBounds = YES;
    [self addSubview:imageView];
    _imageView = imageView;
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self addSubview:activityIndicator];
    self.activityIndicator = activityIndicator;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    self.activityIndicator.frame = self.bounds;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
}

@end
