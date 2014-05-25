//
//  PLCMapStore.h
//  Places
//
//  Created by Jack Flintermann on 5/22/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const PLCCurrentMapDidChangeNotification;

@class PLCMap;

@interface PLCMapStore : NSObject

+ (instancetype)sharedInstance;
- (NSArray *)allMaps;
- (PLCMap *)mapAtIndex:(NSUInteger)index;
@property(nonatomic, strong)PLCMap *selectedMap;

@end
