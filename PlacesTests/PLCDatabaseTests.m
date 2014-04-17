//
//  PLCDatabaseTests.m
//  Places
//
//  Created by Cameron Spickert on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PLCDatabase.h"

@interface PLCDatabaseTests : XCTestCase

@property (nonatomic) PLCDatabase *database;

@end

@implementation PLCDatabaseTests

- (void)setUp
{
    [super setUp];
    [self deleteDatabaseStore];
    self.database = [[PLCDatabase alloc] initWithModelURL:[self databaseModelURL] storeURL:[self databaseStoreURL]];
}

- (void)tearDown
{
    self.database = nil;
    [self deleteDatabaseStore];
    [super tearDown];
}

- (void)testStoreCreation
{
    XCTAssertFalse([self databaseStoreFileExists]);
    XCTAssertNotNil(self.database.mainContext);
    XCTAssertTrue([self databaseStoreFileExists]);
}

#pragma mark -
#pragma mark Helpers

- (NSURL *)databaseModelURL
{
    return [[NSBundle bundleForClass:[self class]] URLForResource:@"Places" withExtension:@"momd"];
}

- (NSURL *)databaseStoreURL
{
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[@"Places" stringByAppendingPathExtension:@"sqlite"]]];
}

- (BOOL)databaseStoreFileExists
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[[self databaseStoreURL] path]];
}

- (void)deleteDatabaseStore
{
    [[NSFileManager defaultManager] removeItemAtURL:[self databaseStoreURL] error:NULL];
}

@end
