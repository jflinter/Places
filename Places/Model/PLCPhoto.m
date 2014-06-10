//
//  PLCPhoto.m
//  Places
//
//  Created by Jack Flintermann on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPhoto.h"

@implementation PLCPhoto

- (void)awakeFromInsert {
    [super awakeFromInsert];
    if (!self.uuid) {
        self.uuid = [[NSUUID UUID] UUIDString];
    }
}

- (NSDictionary *)firebaseObject {
    NSData *data = UIImageJPEGRepresentation(self.image, 1.0);
    NSString *base64 = [data base64EncodedStringWithOptions:0];
    return @{PLCPhotoAttributes.image: base64};
}

@end
