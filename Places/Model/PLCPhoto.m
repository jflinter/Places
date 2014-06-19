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

- (void)setImage:(UIImage *)image {
    self.imageData = UIImageJPEGRepresentation(self.image, 1.0);
}

- (UIImage *)image {
    if (self.imageData) {
        return [[UIImage alloc] initWithData:self.imageData];
    }
    return nil;
}

- (NSDictionary *)firebaseObject {
    NSString *base64 = [self.imageData base64EncodedStringWithOptions:0];
    return @{@"image": base64};
}

@end
