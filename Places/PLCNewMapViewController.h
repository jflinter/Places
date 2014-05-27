//
//  PLCNewMapViewController.h
//  Places
//
//  Created by Jack Flintermann on 5/26/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLCNewMapViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionField;

@end
