//
//  NSMutableDictionary+NilSafe.m
//  Places
//
//  Created by Jack Flintermann on 5/31/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "NSMutableDictionary+NilSafe.h"

@implementation NSMutableDictionary (NilSafe)

- (void)jrf_setValueNilSafe:(id)value forKey:(id)key {
    if (value) {
        [self setValue:value forKey:key];
    }
}

@end
