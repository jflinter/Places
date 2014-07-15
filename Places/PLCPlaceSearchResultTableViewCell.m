//
//  PLCPlaceSearchResultTableViewCell.m
//  Places
//
//  Created by Jack Flintermann on 7/14/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPlaceSearchResultTableViewCell.h"

@implementation PLCPlaceSearchResultTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        self.roundedBackground.layer.backgroundColor = highlighted ? [UIColor lightGrayColor].CGColor : [UIColor whiteColor].CGColor;
    } completion:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    // no-op
}

@end
