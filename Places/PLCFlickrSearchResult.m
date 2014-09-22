//
//  PLCFlickrSearchResult.m
//  Places
//
//  Created by Jack Flintermann on 9/21/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCFlickrSearchResult.h"

@interface PLCFlickrSearchResult()
@property(nonatomic, strong)NSURL *thumbnailUrl;
@property(nonatomic, strong)NSURL *photoUrl;
@end

@implementation PLCFlickrSearchResult

+ (instancetype)resultWithResponse:(NSDictionary *)response {
    PLCFlickrSearchResult *result = [self new];
    NSString *urlString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_c.jpg",
                           response[@"farm"],
                           response[@"server"],
                           response[@"id"],
                           response[@"secret"]];
    result.photoUrl = [NSURL URLWithString:urlString];
    NSString *thumbString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_q.jpg",
                           response[@"farm"],
                           response[@"server"],
                           response[@"id"],
                           response[@"secret"]];
    result.thumbnailUrl = [NSURL URLWithString:thumbString];
    return result;
}

- (NSString *)description {
    return [self.photoUrl description];
}

@end
