//
//  PLCAppDelegate.m
//  Places
//
//  Created by Cameron Spickert on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCAppDelegate.h"
#import "PLCDatabase.h"
#import "PLCMapViewController.h"

@interface PLCAppDelegate ()

@property (nonatomic, readonly) PLCDatabase *database;

@end

@implementation PLCAppDelegate

@synthesize database = _database;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    PLCMapViewController *mapViewController = (PLCMapViewController *)self.window.rootViewController;
    mapViewController.database = self.database;

    return YES;
}

#pragma mark -
#pragma mark Database methods

- (PLCDatabase *)database
{
    if (_database == nil) {
        _database = [[PLCDatabase alloc] initWithModelURL:[self databaseModelURL] storeURL:[self databaseStoreURL]];
    }
    return _database;
}

- (NSURL *)databaseModelURL
{
    return [[NSBundle mainBundle] URLForResource:@"Places" withExtension:@"momd"];
}

- (NSURL *)databaseStoreURL
{
    return [[[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL] URLByAppendingPathComponent:[@"Places" stringByAppendingPathExtension:@"sqlite"]];
}

@end
