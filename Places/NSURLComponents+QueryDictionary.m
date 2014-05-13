//
//  NSURLComponents+QueryDictionary.m
//  Places
//
//  Created by Jack Flintermann on 5/2/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "NSURLComponents+QueryDictionary.h"

@implementation NSURLComponents (QueryDictionary)

- (void)setQueryDictionary:(NSDictionary *)queryDictionary {
    NSMutableArray *terms = [NSMutableArray arrayWithCapacity:queryDictionary.count];
    [queryDictionary enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, BOOL *stop) {
        NSString *term = [NSString stringWithFormat:@"%@=%@", key, obj];
        [terms addObject:term];
    }];
    self.query = [terms componentsJoinedByString:@"&"];
}

- (NSDictionary *)queryDictionary {
    NSArray *terms = [self.query componentsSeparatedByString:@"&"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:terms.count];
    for (NSString *term in terms) {
        NSArray *params = [term componentsSeparatedByString:@"="];
        if (params.count == 2) {
            [dictionary setObject:[params lastObject] forKey:[params firstObject]];
        }
    }
    return [dictionary copy];
}

@end
