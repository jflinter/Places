//
//  PLCPlaceSearchResult.h
//  Places
//
//  Created by Jack Flintermann on 7/14/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLCPlaceSearchResult : NSObject

@property(nonatomic, readonly)NSString *title;
@property(nonatomic, readonly)CLLocationCoordinate2D coordinate;
@property(nonatomic, readonly)NSString *addressString;

- (id)initWithResponseDict:(NSDictionary *)dict;

@end
