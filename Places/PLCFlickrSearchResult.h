//
//  PLCFlickrSearchResult.h
//  Places
//
//  Created by Jack Flintermann on 9/21/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLCFlickrSearchResult : NSObject

+ (instancetype)resultWithResponse:(NSDictionary *)response;
@property(nonatomic, readonly, strong)NSURL *thumbnailUrl;
@property(nonatomic, readonly, strong)NSURL *photoUrl;

@end
