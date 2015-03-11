//
//  PLCSelectedMapCache.h
//  Places
//
//  Created by Jack Flintermann on 3/10/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLCMap;

@interface PLCSelectedMapCache : NSObject

+ (instancetype) sharedInstance;
@property(nonatomic)PLCMap *selectedMap;

@end
