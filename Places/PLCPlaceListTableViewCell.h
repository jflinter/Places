//
//  PLCPlaceListTableViewCell.h
//  Places
//
//  Created by Jack Flintermann on 3/16/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLCPlaceListCellViewModel, PLCPlace;

@interface PLCPlaceListTableViewCell : UITableViewCell

@property(nonatomic)PLCPlaceListCellViewModel *viewModel;

@end
