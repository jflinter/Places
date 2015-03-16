//
//  PLCPlaceListTableViewCell.m
//  Places
//
//  Created by Jack Flintermann on 3/16/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import "PLCPlaceListTableViewCell.h"
#import "PLCSelectedMapViewModel.h"
#import "PLCPlace.h"

@implementation PLCPlaceListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithViewModel:(PLCSelectedMapViewModel *)viewModel place:(PLCPlace *)place {
    if (place.title && ![place.title isEqualToString:@""]) {
        self.textLabel.text = place.title;
    } else {
        self.textLabel.text = NSLocalizedString(@"(Untitled)", nil);
    }
    if (place == viewModel.selectedPlace) {
        self.textLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
    } else {
        self.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f];
    }
    if (viewModel.currentLocation && CLLocationCoordinate2DIsValid(viewModel.currentLocation.coordinate)) {
        self.detailTextLabel.text = [viewModel.formatter stringFromDistanceAndBearingFromLocation:viewModel.currentLocation toLocation:place.location];
    } else {
        self.detailTextLabel.text = @"";
    }
}

@end
