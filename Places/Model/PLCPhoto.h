//
//  PLCPhoto.h
//  Places
//
//  Created by Jack Flintermann on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "_PLCPhoto.h"
#import "PLCFirebaseCoding.h"

@interface PLCPhoto : _PLCPhoto<PLCFirebaseCoding>
@property(nonatomic)UIImage *image;
@end
