//
//  PLCShowPlaceViewController.h
//  Places
//
//  Created by Jack Flintermann on 4/19/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PLCPlace;

@interface PLCShowPlaceViewController : UIViewController
@property (strong, nonatomic) PLCPlace *place;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
