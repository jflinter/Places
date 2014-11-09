//
//  PLCPlaceSearchTableViewController.h
//  Places
//
//  Created by Jack Flintermann on 7/14/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLCPlaceSearchTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic) MKCoordinateRegion searchRegion;
@end
