//
//  PLCAppDelegate.m
//  Places
//
//  Created by Cameron Spickert on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCAppDelegate.h"
#import "PLCMapStore.h"
#import "PLCMapViewController.h"
#import "PLCUserStore.h"
#import "PLCPersistentQueue.h"
#import <Firebase/Firebase.h>
#import <Foursquare-API-v2/Foursquare2.h>
#import <FlickrKit/FlickrKit.h>
#import <TMCache/TMCache.h>
#import "HockeySDK.h"
#import "TargetConditionals.h"

#if defined(DEBUG) && TARGET_IPHONE_SIMULATOR
#import <SDStatusBarManager.h>
#endif

@implementation PLCAppDelegate

- (BOOL)application:(__unused UIApplication *)application didFinishLaunchingWithOptions:(__unused NSDictionary *)launchOptions {
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"6ce20bad14fd46cc1d3fecac42002f0c"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];

    [Foursquare2 setupFoursquareWithClientId:@"SKJPF13KUWM2EZSOIXXDDQKMAQFTIOBRW5XFOLD1CZBXWCHH"
                                      secret:@"1VOMRGHBELSCUGIZFVLHXTU54P0R51I1AZ5ZSZTW33WA1C5J"
                                 callbackURL:@""];
    [[FlickrKit sharedFlickrKit] initializeWithAPIKey:@"15c508152bc4a2d17ddd00eb18a43c9a" sharedSecret:@"d9f2ec04c64fe91e"];
    [TMCache sharedCache].diskCache.byteLimit = 200000000;

    // beta offline persistence for firebase queries - will retry offline saves after e.g. app termination
    [Firebase setOption:@"persistence" to:@YES];
    //    removes outstanding puts if you have to debug them
    //    NSURL *firebaseURL = [[[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES
    //    error:NULL] URLByAppendingPathComponent:@"firebase"];
    //    [[NSFileManager defaultManager] removeItemAtURL:firebaseURL error:nil];

    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:14.0f]];
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0f]];

    [[CLLocationManager new] requestWhenInUseAuthorization];
    [[PLCUserStore sharedInstance] beginICloudMonitoring];
    [[PLCPersistentQueue sharedInstance] resume];

#if defined(DEBUG) && TARGET_IPHONE_SIMULATOR
    [[SDStatusBarManager sharedInstance] enableOverrides];
#endif
    [PLCMapStore createDefaultMapIfNecessary];
    return YES;
}

@end
