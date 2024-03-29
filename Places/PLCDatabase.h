//
//  PLCDatabase.h
//  Places
//
//  Created by Cameron Spickert on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface PLCDatabase : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *mainContext;

+ (instancetype)sharedDatabase;

- (instancetype)initWithModelURL:(NSURL *)modelURL storeURL:(NSURL *)storeURL NS_DESIGNATED_INITIALIZER;

@end
