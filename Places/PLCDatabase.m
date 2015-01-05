//
//  PLCDatabase.m
//  Places
//
//  Created by Cameron Spickert on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCDatabase.h"

@interface PLCDatabase ()

@property (nonatomic, copy) NSURL *managedObjectModelURL;
@property (nonatomic, copy) NSURL *persistentStoreURL;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation PLCDatabase

@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainContext = _mainContext;

+ (instancetype)sharedDatabase {
    static PLCDatabase *sharedDatabase;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ sharedDatabase = [[PLCDatabase alloc] initWithModelURL:[self databaseModelURL] storeURL:[self databaseStoreURL]]; });
    return sharedDatabase;
}

+ (NSURL *)databaseModelURL {
    return [[NSBundle mainBundle] URLForResource:@"Places" withExtension:@"momd"];
}

+ (NSURL *)databaseStoreURL {
    return [[[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL]
        URLByAppendingPathComponent:[@"Places" stringByAppendingPathExtension:@"sqlite"]];
}

- (instancetype)initWithModelURL:(NSURL *)modelURL storeURL:(NSURL *)storeURL {
    if ((self = [super init])) {
        _managedObjectModelURL = modelURL;
        _persistentStoreURL = storeURL;
    }
    return self;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel == nil) {
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.managedObjectModelURL];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator == nil) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];

        NSPersistentStore *store = nil;
        if ((store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                               configuration:nil
                                                                         URL:self.persistentStoreURL
                                                                     options:@{
                                                                         NSMigratePersistentStoresAutomaticallyOption: @YES,
                                                                         NSInferMappingModelAutomaticallyOption: @YES
                                                                     } error:nil]) == nil) {
            //            // this is a tiny thing that makes it easy to just build twice in a row on your device/simulator if there is a migration error the
            //            first time. Should be cleaned up eventually.
            //            [[NSFileManager defaultManager] removeItemAtURL:self.persistentStoreURL error:nil];
            abort();
        }
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)mainContext {
    if (_mainContext == nil) {
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    return _mainContext;
}

@end
