//
//  PLCPlaceListTableViewController.m
//  Places
//
//  Created by Jack Flintermann on 3/12/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#import "PLCPlaceListTableViewController.h"
#import "PLCPlace.h"
#import "PLCPlaceListTableViewCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
@import Dwifft;

@interface PLCPlaceListTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;
@property(nonatomic)TableViewDiffCalculator *calculator;
@property(nonatomic)NSArray *orderedPlaces;
@end

@implementation PLCPlaceListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 44.0f;

    RACSignal *placesSignal = [[RACObserve(self, viewModel) map:^id(PLCSelectedMapViewModel *viewModel) {
        return RACObserve(viewModel, places);
    }] switchToLatest];
    
    [placesSignal subscribeNext:^(NSSet *places) {
        self.emptyLabel.hidden = (places.count > 0);
    }];
    
    self.calculator = [[TableViewDiffCalculator alloc] initWithTableView:self.tableView];
    self.calculator.insertionAnimation = UITableViewRowAnimationFade;
    self.calculator.deletionAnimation = UITableViewRowAnimationFade;
    
    RAC(self.calculator, rows) = RACObserve(self, orderedPlaces);
    
    [[[RACObserve(self, viewModel) map:^id(PLCSelectedMapViewModel *viewModel) {
        return RACObserve(viewModel, selectedPlace);
    }] switchToLatest] subscribeNext:^(PLCPlace *selectedPlace) {
        NSInteger idx = [self.orderedPlaces indexOfObject:selectedPlace];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }];
    
    [[RACSignal combineLatest:@[
                                placesSignal,
                                [[RACObserve(self, viewModel) map:^id(PLCSelectedMapViewModel *viewModel) {
                                    return RACObserve(viewModel, currentLocation);
                                }] switchToLatest]
                              ] reduce:^id(NSSet *places, CLLocation *location) {
                                  return [places.allObjects sortedArrayUsingComparator:^NSComparisonResult(PLCPlace *obj1, PLCPlace *obj2) {
                                      if ([obj1.location distanceFromLocation:location] > [obj2.location distanceFromLocation:location]) {
                                          return NSOrderedDescending;
                                      }
                                      return NSOrderedAscending;
                                  }];
                              }] subscribeNext:^(NSArray *places) {
                                  self.orderedPlaces = places;
                              }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.emptyLabel.frame = ({
        CGRect rect = self.emptyLabel.frame;
        rect.size.width = CGRectGetWidth(self.emptyLabel.superview.frame) - 40;
        rect.origin.x = 20;
        rect;
    });
}

#pragma mark - Table view data source

- (NSInteger)tableView:(__unused UITableView *)tableView numberOfRowsInSection:(__unused NSInteger)section {
    return self.calculator.rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PLCPlaceListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLCPlaceListCellIdentifier" forIndexPath:indexPath];
    PLCPlace *place = self.orderedPlaces[indexPath.row];
    [cell configureWithViewModel:self.viewModel place:place];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PLCPlace *place = self.orderedPlaces[indexPath.row];
    self.viewModel.selectedPlace = place;
}

@end
