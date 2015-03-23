//
//  PLCMapRowViewModel.h
//  Places
//
//  Created by Jack Flintermann on 3/11/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLCMap;

@interface PLCMapRowViewModel : NSObject

- (instancetype)initWithMap:(PLCMap *)map;

@property(nonatomic, readonly)NSString *title;
@property(nonatomic, readonly)BOOL selected;
@property(nonatomic)BOOL detailShown;

- (CGFloat)rowHeight;

@end
