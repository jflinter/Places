//
//  PLCNewMapViewController.m
//  Places
//
//  Created by Jack Flintermann on 5/26/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCNewMapViewController.h"
#import "PLCMapStore.h"

@implementation PLCNewMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [UIFont fontWithName:@"AvenirNext-Medium" size:14.0f];
    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.clipsToBounds = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.nameField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    PLCMapStore *store = [PLCMapStore sharedInstance];
    store.selectedMap = [store insertMapWithName:textField.text];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

@end
