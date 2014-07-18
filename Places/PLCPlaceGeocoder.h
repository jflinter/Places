//
//  PLCPlaceGeocoder.h
//  Places
//
//  Created by Jack Flintermann on 7/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLCPlace;

@interface PLCPlaceGeocoder : NSObject

+(instancetype)sharedInstance;
-(void)reverseGeocodePlace:(PLCPlace *)place;
- (void)resumeGeocoding;

@end
