//
//  PLCCalloutViewController.h
//  Places
//
//  Created by Jack Flintermann on 4/19/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLCPlace;

@interface PLCCalloutViewController : UIViewController<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpacingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *placeImageView;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic) PLCPlace *place;

+ (CGSize)calloutSize;

- (IBAction)deletePlace:(id)sender;
- (IBAction)choosePhoto:(id)sender;
- (IBAction)sharePlace:(id)sender;

@end
