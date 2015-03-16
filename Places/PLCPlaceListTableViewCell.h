//
//  PLCPlaceListTableViewCell.h
//  Places
//
//  Created by Jack Flintermann on 3/16/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLCSelectedMapViewModel, PLCPlace;

@interface PLCPlaceListTableViewCell : UITableViewCell

- (void)configureWithViewModel:(PLCSelectedMapViewModel *)viewModel place:(PLCPlace *)place;

@end
