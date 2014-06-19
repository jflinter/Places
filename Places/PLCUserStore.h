//
//  PLCUserStore.h
//  Places
//
//  Created by Jack Flintermann on 5/30/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLCUserStore : NSObject

+ (instancetype)sharedInstance;
- (void)beginICloudMonitoring;
- (NSString *)currentUserId;

@end
