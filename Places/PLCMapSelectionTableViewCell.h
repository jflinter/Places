//
//  PLCMapSelectionTableViewCell.h
//  Places
//
//  Created by Jack Flintermann on 9/13/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell/SWTableViewCell.h>
#import "PLCMapRowViewModel.h"

@class PLCMapSelectionTableViewCell;

@protocol PLCMapSelectionCellDelegate <NSObject>

- (void)tableViewCell:(PLCMapSelectionTableViewCell *)cell textDidChange:(NSString *)text;
- (void)tableViewCellDidDelete:(PLCMapSelectionTableViewCell *)cell;

@end

@interface PLCMapSelectionTableViewCell : SWTableViewCell
@property (weak, nonatomic) IBOutlet UITextField *editTitleTextField;
@property (weak, nonatomic) id<PLCMapSelectionCellDelegate> cellDelegate;

- (void)configureWithViewModel:(PLCMapRowViewModel *)viewModel;

@end
