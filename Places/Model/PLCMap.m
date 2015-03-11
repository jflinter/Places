//
//  PLCMap.m
//  Places
//
//  Created by Cameron Spickert on 5/8/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCMap.h"
#import "PLCPlace.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation PLCMap

- (void)awakeFromInsert {
    [super awakeFromInsert];
    if (!self.uuid) {
        self.uuid = [[NSUUID UUID] UUIDString];
    }
}

- (NSArray *)activePlaces {
    return [[self.places.rac_sequence filter:^BOOL(PLCPlace *place) {
        return CLLocationCoordinate2DIsValid(place.coordinate);
    }] filter:^BOOL(PLCPlace *place) {
        return place.deletedAt == nil;
    }].array;
}

- (NSDictionary *)firebaseObject {
    return @{ PLCMapAttributes.name: self.name, @"PLCDeletedAt": @(self.deletedAt.timeIntervalSinceReferenceDate), PLCMapAttributes.urlId: self.urlId };
}

- (NSURL *)shareURL {
    NSString *string = [NSString stringWithFormat:@"http://shareplac.es/#!/%@", self.urlId];
    return [NSURL URLWithString:string];
}

+ (NSSet *)keyPathsForValuesAffectingActivePlaces {
    return [NSSet setWithObject:@"places"];
}

@end
