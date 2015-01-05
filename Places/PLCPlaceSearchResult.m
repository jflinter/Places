//
//  PLCPlaceSearchResult.m
//  Places
//
//  Created by Jack Flintermann on 7/14/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPlaceSearchResult.h"

@interface PLCPlaceSearchResult()

@property(nonatomic)NSString *title;
@property(nonatomic)CLLocationCoordinate2D coordinate;
@property(nonatomic)NSString *addressString;

@end

@implementation PLCPlaceSearchResult

- (instancetype)initWithResponseDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _title = [dict valueForKey:@"name"];
        NSDictionary *location = [dict valueForKey:@"location"];
        CLLocationDegrees lat = [[location valueForKey:@"lat"] doubleValue];
        CLLocationDegrees lng = [[location valueForKey:@"lng"] doubleValue];
        _coordinate = CLLocationCoordinate2DMake(lat, lng);
        NSMutableArray *addressComponents = [@[] mutableCopy];
        NSString *address = [location valueForKey:@"address"];
        if (address) {
            [addressComponents addObject:address];
        }
        NSString *crossStreet = [location valueForKey:@"crossStreet"];
        if (crossStreet && ![crossStreet isEqualToString:@""]) {
            NSString *format = [NSString stringWithFormat:@"(%@)", crossStreet];
            [addressComponents addObject:format];
        }
        _addressString = [addressComponents componentsJoinedByString:@" "];
    }
    return self;
}

- (BOOL)isEqual:(PLCPlaceSearchResult *)object {
    if ([object isKindOfClass:[PLCPlaceSearchResult class]]) {
        return [object.title isEqualToString:self.title] &&
        fequal(object.coordinate.latitude, self.coordinate.latitude) &&
        fequal(object.coordinate.longitude, self.coordinate.longitude) &&
        [object.addressString isEqualToString:self.addressString];
    }
    return false;
}

- (NSUInteger)hash {
    return [self.title hash];
}

@end
