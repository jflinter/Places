//
//  PLCMapSelectionTableViewCell.m
//  Places
//
//  Created by Jack Flintermann on 9/13/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCMapSelectionTableViewCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PLCMapSelectionTableViewCell()<UITextFieldDelegate, SWTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property(nonatomic)PLCMapRowViewModel *viewModel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIView *highlightView;
@end

@implementation PLCMapSelectionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.separatorView.backgroundColor = [self highlightColor];
    self.highlightView.backgroundColor = [self highlightColor];
    self.highlightView.alpha = 0;
    [[self.deleteButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__unused id x) {
        [self.cellDelegate tableViewCellDidDelete:self];
    }];
    [[self.editButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__unused id x) {
        
    }];
}

- (void)configureWithViewModel:(PLCMapRowViewModel *)viewModel {
    self.viewModel = viewModel;
    RAC(self.titleLabel, text) = [RACObserve(viewModel, title) takeUntil:self.rac_prepareForReuseSignal];
    RAC(self.detailButton, selected) = [RACObserve(self.viewModel, detailShown) takeUntil:self.rac_prepareForReuseSignal];
    RAC(self.titleLabel, font) = [[RACObserve(self.viewModel, selected) map:^UIFont *(NSNumber *selected) {
        return selected.boolValue ? [UIFont fontWithName:@"AvenirNext-DemiBold" size:18.0f] : [UIFont fontWithName:@"AvenirNext-Regular" size:18.0f];
    }] takeUntil:self.rac_prepareForReuseSignal];
}

- (void)setHighlighted:(BOOL)highlighted animated:(__unused BOOL)animated {
    [UIView animateWithDuration:0.1 animations:^{
        self.highlightView.alpha = (1.0 * highlighted);
    }];
}

- (UIColor *)highlightColor {
    return [UIColor colorWithRed:127.0/255.0 green:153.0/255.0 blue:174.0/255.0 alpha:0.9];
}


@end
