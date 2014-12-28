//
//  PLCPersistentQueue.h
//  Places
//
//  Created by Jack Flintermann on 12/28/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PLCAsynchronousWorkCallback)(NSError *error);

@protocol PLCAsynchronousWork<NSCoding>

- (void)doWork:(PLCAsynchronousWorkCallback)completion;

@end

@interface PLCPersistentQueue : NSObject

+ (instancetype)sharedInstance;
- (void)resume;
- (void)addWork:(id<PLCAsynchronousWork>)work;

@end
