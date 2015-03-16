//
//  PLCPlaceListTableViewController.h
//  Places
//
//  Created by Jack Flintermann on 3/12/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLCSelectedMapViewModel.h"

@interface PLCPlaceListTableViewController : UITableViewController
@property(nonatomic)PLCSelectedMapViewModel *viewModel;
@end
