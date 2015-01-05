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

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *activePlaces;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSURL *shareURL;

@end
