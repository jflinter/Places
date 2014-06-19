//
//  PLCMap.m
//  Places
//
//  Created by Cameron Spickert on 5/8/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCMap.h"

@implementation PLCMap

- (void)awakeFromInsert {
    [super awakeFromInsert];
    if (!self.uuid) {
        self.uuid = [[NSUUID UUID] UUIDString];
    }
}

- (NSDictionary *)firebaseObject {
    return @{PLCMapAttributes.name: self.name};
}

- (NSURL *)shareURL {
    NSString *string = [NSString stringWithFormat:@"https://shareplaces.firebaseapp.com/#/maps/%@", self.uuid];
    return [NSURL URLWithString:string];
}

@end
