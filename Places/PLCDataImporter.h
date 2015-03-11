//
//  PLCDataImporter.h
//  Places
//
//  Created by Jack Flintermann on 3/10/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLCDataImporter : NSObject

+ (void)downloadMapsForUserId:(__unused NSString *)userId;

@end
