//
//  PLCShowPlaceViewController.m
//  Places
//
//  Created by Jack Flintermann on 4/19/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCShowPlaceViewController.h"
#import "PLCPlace.h"

@implementation PLCShowPlaceViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPlace:)];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.imageView.image = self.place.image;
}

- (void)setPlace:(PLCPlace *)place {
    _place = place;
    self.imageView.image = place.image;
}

- (void) editPlace:(id)sender {
    [self performSegueWithIdentifier:@"PLCEditPlaceViewControllerPushSegue" sender:sender];
}

@end
