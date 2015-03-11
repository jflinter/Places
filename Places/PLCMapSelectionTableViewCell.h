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

@interface PLCMapSelectionTableViewCell : SWTableViewCell
@property (weak, nonatomic) IBOutlet UITextField *editTitleTextField;

- (void)configureWithViewModel:(PLCMapRowViewModel *)viewModel;

@end
