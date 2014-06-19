//
//  NSMutableDictionary+NilSafe.h
//  Places
//
//  Created by Jack Flintermann on 5/31/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (NilSafe)

- (void)setValueNilSafe:(id)value forKey:(id)key;

@end
