//
//  PLCUserStore.m
//  Places
//
//  Created by Jack Flintermann on 5/30/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCUserStore.h"
#import "PLCDataImporter.h"
#import "Firebase+Places.h"

static NSString *const PLCPlacesDeviceIdentifiersKey = @"PLCPlacesDeviceIdentifiers";

@implementation PLCUserStore

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ sharedInstance = [self new]; });
    return sharedInstance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)beginICloudMonitoring {
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];

    [self updateUbiquitousDeviceIdentifiers];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUbiquitousDeviceIdentifiers:)
                                                 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                               object:[NSUbiquitousKeyValueStore defaultStore]];
}

- (void)updateUbiquitousDeviceIdentifiers {
    [self updateUbiquitousDeviceIdentifiers:nil];
}

- (void)updateUbiquitousDeviceIdentifiers:(__unused NSNotification *)notification {
    NSString *identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    NSMutableOrderedSet *allIdentifiers =
        [NSMutableOrderedSet orderedSetWithArray:[[NSUbiquitousKeyValueStore defaultStore] arrayForKey:PLCPlacesDeviceIdentifiersKey] ?: @[]];
    if (![allIdentifiers containsObject:identifier]) {
        for (NSString *userId in allIdentifiers) {
            [PLCDataImporter downloadMapsForUserId:userId];
        }
    }
    [allIdentifiers addObject:identifier];

    [[NSUbiquitousKeyValueStore defaultStore] setArray:[allIdentifiers array] forKey:PLCPlacesDeviceIdentifiersKey];
}

- (NSString *)currentUserId {
    NSArray *array = [[NSUbiquitousKeyValueStore defaultStore] objectForKey:PLCPlacesDeviceIdentifiersKey];
    return [array lastObject];
}

@end
