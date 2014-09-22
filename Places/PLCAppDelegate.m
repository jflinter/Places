//
//  PLCAppDelegate.m
//  Places
//
//  Created by Cameron Spickert on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCAppDelegate.h"
#import "PLCMapViewController.h"
#import "PLCUserStore.h"
#import "PLCPlaceGeocoder.h"
#import <Firebase/Firebase.h>
#import <Foursquare-API-v2/Foursquare2.h>
#import <FlickrKit/FlickrKit.h>

@implementation PLCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Foursquare2 setupFoursquareWithClientId:@"SKJPF13KUWM2EZSOIXXDDQKMAQFTIOBRW5XFOLD1CZBXWCHH"
                                      secret:@"1VOMRGHBELSCUGIZFVLHXTU54P0R51I1AZ5ZSZTW33WA1C5J" callbackURL:@""];
    [[FlickrKit sharedFlickrKit] initializeWithAPIKey:@"15c508152bc4a2d17ddd00eb18a43c9a"
                                         sharedSecret:@"d9f2ec04c64fe91e"];
    
    
    // beta offline persistence for firebase queries - will retry offline saves after e.g. app termination
    [Firebase setOption:@"persistence" to:@YES];
//    removes outstanding puts if you have to debug them
//    NSURL *firebaseURL = [[[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL] URLByAppendingPathComponent:@"firebase"];
//    [[NSFileManager defaultManager] removeItemAtURL:firebaseURL error:nil];
    
    [[CLLocationManager new] requestWhenInUseAuthorization];
    [[PLCUserStore sharedInstance] beginICloudMonitoring];
    [[PLCPlaceGeocoder sharedInstance] resumeGeocoding];
    return YES;
}

@end
