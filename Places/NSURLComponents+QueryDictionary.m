//
//  NSURLComponents+QueryDictionary.m
//  Places
//
//  Created by Jack Flintermann on 5/2/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "NSURLComponents+QueryDictionary.h"

@implementation NSURLComponents (QueryDictionary)

- (void)setJrf_queryDictionary:(NSDictionary *)jrf_queryDictionary {
    NSMutableArray *terms = [NSMutableArray arrayWithCapacity:jrf_queryDictionary.count];
    [jrf_queryDictionary enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, __unused BOOL *stop) {
        NSString *term = [NSString stringWithFormat:@"%@=%@", key, obj];
        [terms addObject:term];
    }];
    self.query = [terms componentsJoinedByString:@"&"];
}

- (NSDictionary *)jrf_queryDictionary {
    NSArray *terms = [self.query componentsSeparatedByString:@"&"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:terms.count];
    for (NSString *term in terms) {
        NSArray *params = [term componentsSeparatedByString:@"="];
        if (params.count == 2) {
            dictionary[[params firstObject]] = [params lastObject];
        }
    }
    return [dictionary copy];
}

@end
