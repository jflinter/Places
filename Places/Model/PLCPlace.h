//
//  PLCPlace.h
//  Places
//
//  Created by Cameron Spickert on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "_PLCPlace.h"
#import "PLCFirebaseCoding.h"

typedef NS_ENUM(NSUInteger, PLCPlaceType) {
    PLCPlaceTypeEat,
    PLCPlaceTypeDrink,
    PLCPlaceTypeDo,
};

@interface PLCPlace : _PLCPlace<MKAnnotation, UIActivityItemSource, PLCFirebaseCoding>
@property(nonatomic)UIImage *image;
@property(nonatomic, readonly)NSString *imageId;
@property (NS_NONATOMIC_IOSONLY, readonly) PLCPlaceType type;
@property(nonatomic, readonly)CLLocation *location;
@property(nonatomic, readonly, copy)NSString *title;
@end
