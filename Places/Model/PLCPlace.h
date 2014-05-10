//
//  PLCPlace.h
//  Places
//
//  Created by Cameron Spickert on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "_PLCPlace.h"

@interface PLCPlace : _PLCPlace<MKAnnotation, UIActivityItemSource>
- (UIImage *)image;

// this will default to no, so it doesn't need to be synced or anything, it's just so we can immediately begin editing newly added places.
@property(nonatomic, readwrite) BOOL wasJustAdded;

@end
