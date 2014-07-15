//
//  PLCPlaceSearchResultTableViewCell.h
//  Places
//
//  Created by Jack Flintermann on 7/14/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLCPlaceSearchResultTableViewCell : UITableViewCell

@property(nonatomic) IBOutlet UILabel *nameLabel;
@property(nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIView *roundedBackground;

@end
