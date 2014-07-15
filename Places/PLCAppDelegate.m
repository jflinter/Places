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
#import <Firebase/Firebase.h>
#import <Foursquare-API-v2/Foursquare2.h>

@implementation PLCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Foursquare2 setupFoursquareWithClientId:@"SKJPF13KUWM2EZSOIXXDDQKMAQFTIOBRW5XFOLD1CZBXWCHH"
                                      secret:@"1VOMRGHBELSCUGIZFVLHXTU54P0R51I1AZ5ZSZTW33WA1C5J" callbackURL:@""];
    
    // beta offline persistence for firebase queries - will retry offline saves after e.g. app termination
    [Firebase setOption:@"persistence" to:@YES];
    [[PLCUserStore sharedInstance] beginICloudMonitoring];
    return YES;
}

@end
