//
//  PLCUserStore.m
//  Places
//
//  Created by Jack Flintermann on 5/30/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCUserStore.h"
#import "PLCMapStore.h"

static NSString *const PLCPlacesDeviceIdentifiersKey = @"PLCPlacesDeviceIdentifiers";

@implementation PLCUserStore

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ sharedInstance = [self new]; });
    return sharedInstance;
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

- (void)updateUbiquitousDeviceIdentifiers:(NSNotification *)notification {
    NSString *identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    NSMutableOrderedSet *allIdentifiers =
        [NSMutableOrderedSet orderedSetWithArray:[[NSUbiquitousKeyValueStore defaultStore] arrayForKey:PLCPlacesDeviceIdentifiersKey] ?: @[]];
    if (![allIdentifiers containsObject:identifier]) {
        [[PLCMapStore sharedInstance] downloadMapsForUserId:identifier];
    }
    [allIdentifiers addObject:identifier];

    [[NSUbiquitousKeyValueStore defaultStore] setArray:[allIdentifiers array] forKey:PLCPlacesDeviceIdentifiersKey];
}

- (NSString *)currentUserId {
    NSArray *array = [[NSUbiquitousKeyValueStore defaultStore] objectForKey:PLCPlacesDeviceIdentifiersKey];
    return [array lastObject];
}

@end
