//
//  PLCPlaceCalloutViewModel.h
//  Places
//
//  Created by Jack Flintermann on 3/17/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLCSelectedMapViewModel.h"

@interface PLCPlaceCalloutViewModel : NSObject

- (instancetype)initWithParentViewModel:(PLCSelectedMapViewModel *)parentViewModel place:(PLCPlace *)place;

@property(nonatomic, readonly)PLCPlace *place;

- (BOOL)hasCaption;

- (void)removePlace;
- (void)renamePlaceWithTitle:(NSString *)title;

- (UIActivityViewController *)activityViewControllerForSharingPlace;

@end
