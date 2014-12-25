//
//  PLCMap.m
//  Places
//
//  Created by Cameron Spickert on 5/8/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCMap.h"
#import "PLCPlace.h"

@implementation PLCMap

- (void)awakeFromInsert {
    [super awakeFromInsert];
    if (!self.uuid) {
        self.uuid = [[NSUUID UUID] UUIDString];
    }
}

- (NSArray *)activePlaces {
    NSExpression *nilExpression = [NSExpression expressionForConstantValue:[NSNull null]];
    NSExpression *deletedAtExpression = [NSExpression expressionForKeyPath:PLCPlaceAttributes.deletedAt];
    NSPredicate *notDeletedPredicate = [NSComparisonPredicate predicateWithLeftExpression:deletedAtExpression
                                                                          rightExpression:nilExpression
                                                                                 modifier:NSDirectPredicateModifier
                                                                                     type:NSEqualToPredicateOperatorType
                                                                                  options:0];
    return [[[self.places filteredSetUsingPredicate:notDeletedPredicate]
        filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(PLCPlace *evaluatedObject, NSDictionary *bindings) {
                                      return CLLocationCoordinate2DIsValid(evaluatedObject.coordinate);
                                  }]] allObjects];
}

- (NSDictionary *)firebaseObject {
    return @{ PLCMapAttributes.name: self.name, @"PLCDeletedAt": @(self.deletedAt.timeIntervalSinceReferenceDate), PLCMapAttributes.urlId: self.urlId };
}

- (NSURL *)shareURL {
    NSString *string = [NSString stringWithFormat:@"http://shareplac.es/#!/%@", self.urlId];
    return [NSURL URLWithString:string];
}

@end
