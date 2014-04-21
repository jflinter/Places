//
//  PLCAppDelegate.m
//  Places
//
//  Created by Cameron Spickert on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCAppDelegate.h"
#import "PLCMapViewController.h"

@implementation PLCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIImage *transparentImage = [UIImage imageNamed:@"Transparent"];
    [[UINavigationBar appearance] setBackgroundImage:transparentImage forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:transparentImage];
    return YES;
}

@end
