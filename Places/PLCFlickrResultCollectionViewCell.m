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
@end

@implementation PLCFlickrResultCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
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
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
}

- (void)setImageUrl:(NSURL *)url animated:(BOOL)animated {
    [self.imageView cancelImageRequestOperation];
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        self.imageView.alpha = 0.0f;
    } completion:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [self.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.imageView.image = image;
        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
            self.imageView.alpha = 1.0f;
        } completion:nil];
    } failure:nil];
}

@end
