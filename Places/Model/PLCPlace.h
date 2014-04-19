//
//  PLCPlace.h
//  Places
//
//  Created by Cameron Spickert on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "_PLCPlace.h"

@interface PLCPlace : _PLCPlace<MKAnnotation>
@property(nonatomic, readwrite) UIImage *image;
@end
