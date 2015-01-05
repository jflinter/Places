//
//  PLCPlaceSearchResultTableViewCell.m
//  Places
//
//  Created by Jack Flintermann on 7/14/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPlaceSearchResultTableViewCell.h"

@interface PLCPlaceSearchResultTableViewCell()
@property(nonatomic, weak)UIView *roundedBackground;
@end

@implementation PLCPlaceSearchResultTableViewCell

- (instancetype)initWithStyle:(__unused UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18.0f];
        self.detailTextLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:14.0f];
        self.backgroundColor = [UIColor clearColor];
        UIView *roundedBackground = [[UIView alloc] initWithFrame:self.bounds];
        roundedBackground.layer.cornerRadius = 5.0f;
        [self insertSubview:roundedBackground atIndex:0];
        _roundedBackground = roundedBackground;
        _roundedBackground.layer.backgroundColor = [UIColor whiteColor].CGColor;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.roundedBackground.frame = CGRectInset(self.bounds, 2, 2);
}

- (void)setHighlighted:(BOOL)highlighted animated:(__unused BOOL)animated {
    [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        self.roundedBackground.alpha = highlighted ? 0.8f : 0.55f;
    } completion:nil];
}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    // no-op
//}

@end
