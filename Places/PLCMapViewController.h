//
//  PLCMapViewController.h
//  Places
//
//  Created by Cameron Spickert on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLCMapViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
- (IBAction)showLocation:(id)sender;

@end
