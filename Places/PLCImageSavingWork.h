//
//  PLCImageSavingWork.h
//  Places
//
//  Created by Jack Flintermann on 12/29/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "PLCPersistentQueue.h"

@interface PLCImageSavingWork : MTLModel<PLCAsynchronousWork>
- (instancetype)initWithImage:(NSData *)imageData imageId:(NSString *)imageId placeId:(NSString *)placeId NS_DESIGNATED_INITIALIZER;
@end
