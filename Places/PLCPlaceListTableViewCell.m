//
//  PLCPlaceListTableViewCell.m
//  Places
//
//  Created by Jack Flintermann on 3/16/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import "PLCPlaceListTableViewCell.h"
#import "PLCPlaceListCellViewModel.h"
#import "PLCPlace.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation PLCPlaceListTableViewCell

- (void)awakeFromNib {

    [[[RACObserve(self, viewModel) map:^id(PLCPlaceListCellViewModel *viewModel) {
        return viewModel.selectedSignal;
    }] switchToLatest] subscribeNext:^(NSNumber *selected) {
        UIFont *font = selected.boolValue ? [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f] : [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f];
        self.textLabel.font = font;
    }];
    
    RAC(self.textLabel, text) = [[RACObserve(self, viewModel) map:^id(PLCPlaceListCellViewModel *viewModel) {
        return viewModel.titleSignal;
    }] switchToLatest];
    RAC(self.detailTextLabel, text) = [[RACObserve(self, viewModel) map:^id(PLCPlaceListCellViewModel *viewModel) {
        return viewModel.subtitleSignal;
    }] switchToLatest];

}

- (void)layoutSubviews {
    [UIView performWithoutAnimation:^{
        [super layoutSubviews];
    }];
}

@end
