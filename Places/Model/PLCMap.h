//
//  PLCMap.h
//  Places
//
//  Created by Cameron Spickert on 5/8/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "_PLCMap.h"
#import "PLCFirebaseCoding.h"

@interface PLCMap : _PLCMap<PLCFirebaseCoding>

- (NSArray *)activePlaces;
- (NSURL *)shareURL;

@end
