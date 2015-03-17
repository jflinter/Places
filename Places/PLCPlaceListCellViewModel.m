//
//  PLCPlaceListCellViewModel.m
//  Places
//
//  Created by Jack Flintermann on 3/17/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import "PLCPlaceListCellViewModel.h"
#import "PLCPlace.h"
#import <FormatterKit/TTTLocationFormatter.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

NSString * const PLCLocationFormatterKey = @"PLCLocationFormatterKey";

@interface PLCPlaceListCellViewModel()
@property(nonatomic)PLCPlace *place;
@end

@implementation PLCPlaceListCellViewModel

- (instancetype)initWithPlace:(PLCPlace *)place {
    self = [super init];
    if (self) {
        _place = place;
        _titleSignal = [RACObserve(place, title) map:^id(NSString *title) {
            if (title && ![title isEqualToString:@""]) {
                return title;
            } else {
                return NSLocalizedString(@"(Untitled)", nil);
            }

        }];
        _subtitleSignal = [RACSignal combineLatest:@[
                                                     RACObserve(place, location),
                                                     RACObserve(self, currentLocation),
                                                     ] reduce:^id(CLLocation *placeLocation, CLLocation *userLocation){
                                                         if (placeLocation && userLocation) {
                                                             return [[self.class formatter] stringFromDistanceAndBearingFromLocation:userLocation toLocation:placeLocation];
                                                         }
                                                         return NSLocalizedString(@"Locating...", nil);
        }];
        _selectedSignal = [RACObserve(self, selectedPlace) map:^id(PLCPlace *p) {
            return @([self.place isEqual:p]);
        }];
        
    }
    return self;
}

+ (TTTLocationFormatter *) formatter {
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    TTTLocationFormatter *formatter = [threadDictionary objectForKey:PLCLocationFormatterKey];
    if (!formatter) {
        formatter = [[TTTLocationFormatter alloc] init];
        formatter.bearingStyle = TTTBearingAbbreviationWordStyle;
        [threadDictionary setObject:formatter forKey:PLCLocationFormatterKey];
    }
    return formatter;
}

@end
