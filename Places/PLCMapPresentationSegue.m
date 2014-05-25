//
//  PLCMapPresentationSegue.m
//  Places
//
//  Created by Jack Flintermann on 5/23/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCMapPresentationSegue.h"
#import "PLCMapSelectionTransitionAnimator.h"
#import "PLCMapViewController.h"

@implementation PLCMapPresentationSegue

- (void) perform {
    UIViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;
    [sourceViewController presentViewController:destinationViewController animated:YES completion:nil];
}

@end
