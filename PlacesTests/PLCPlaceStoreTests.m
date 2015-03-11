//
//  PLCPlaceStoreTests.m
//  Places
//
//  Created by Jack Flintermann on 3/10/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLCPlaceStore.h"
#import "PLCMap.h"

@interface PLCPlaceStoreTests : XCTestCase
@property(nonatomic)PLCMap *map;
@end

@implementation PLCPlaceStoreTests

- (void)setUp {
    [super setUp];
    self.map = [PLCMapStore createMapWithName:@"Test"];
}

- (void)testInsertingPlaceTriggersMapSignal {
    XCTestExpectation *expectation = [self expectationWithDescription:@"activePlaces"];
    [RACObserve(self, map.activePlaces) subscribeNext:^(NSArray* places) {
        if (places.count != 0) {
            [expectation fulfill];
        }
    }];
    [PLCPlaceStore insertPlaceOntoMap:self.map atCoordinate:CLLocationCoordinate2DMake(10, 10)];
    [self waitForExpectationsWithTimeout:5.0f handler:nil];
}

- (void)testDeletingPlaceTriggersMapSignal {
    XCTestExpectation *expectation = [self expectationWithDescription:@"activePlaces"];
    PLCPlace *place = [PLCPlaceStore insertPlaceOntoMap:self.map atCoordinate:CLLocationCoordinate2DMake(10, 10)];
    [RACObserve(self, map.activePlaces) subscribeNext:^(NSArray* places) {
        if (places.count == 0) {
            [expectation fulfill];
        }
    }];
    [PLCPlaceStore removePlace:place fromMap:self.map];
    [self waitForExpectationsWithTimeout:5.0f handler:nil];
}

@end
