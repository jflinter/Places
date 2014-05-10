//
//  PLCAppDelegate.m
//  Places
//
//  Created by Cameron Spickert on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCAppDelegate.h"
#import "PLCMapViewController.h"

static NSString *const PLCPlacesDeviceIdentifiersKey = @"PLCPlacesDeviceIdentifiers";

@implementation PLCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIImage *transparentImage = [UIImage imageNamed:@"Transparent"];
    [[UINavigationBar appearance] setBackgroundImage:transparentImage forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:transparentImage];

    [[NSUbiquitousKeyValueStore defaultStore] synchronize];

    [self updateUbiquitousDeviceIdentifiers];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUbiquitousDeviceIdentifiers:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:[NSUbiquitousKeyValueStore defaultStore]];

    return YES;
}

- (void)updateUbiquitousDeviceIdentifiers
{
    [self updateUbiquitousDeviceIdentifiers:nil];
}

- (void)updateUbiquitousDeviceIdentifiers:(NSNotification *)notification
{
    NSString *identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    NSMutableOrderedSet *allIdentifiers = [NSMutableOrderedSet orderedSetWithArray:[[NSUbiquitousKeyValueStore defaultStore] arrayForKey:PLCPlacesDeviceIdentifiersKey] ?: @[]];
    [allIdentifiers addObject:identifier];

    [[NSUbiquitousKeyValueStore defaultStore] setArray:[allIdentifiers array] forKey:PLCPlacesDeviceIdentifiersKey];
}

@end
