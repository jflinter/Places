//
//  PLCMapSelectionTableViewController.m
//  Places
//
//  Created by Jack Flintermann on 5/23/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCMapSelectionTableViewController.h"
#import "PLCMap.h"
#import "PLCMapStore.h"
#import "PLCMapSelectionTableViewCell.h"
#import "PLCSelectedMapCache.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
@import Dwifft;

@interface PLCMapSelectionTableViewController () <PLCMapSelectionCellDelegate, UITextFieldDelegate>
@property(nonatomic)TableViewDiffCalculator *calculator;
@property(nonatomic)NSMutableDictionary *viewModels;
@end

@implementation PLCMapSelectionTableViewController

#pragma mark - Table view data source

- (void)viewDidLoad {
    self.viewModels = [@{} mutableCopy];
    self.calculator = [[TableViewDiffCalculator alloc] initWithTableView:self.tableView];
    RAC(self.calculator, rows) = RACObserve(self, maps);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.view.layer.allowsGroupOpacity = NO;
    [self.navigationController.navigationBar.layer removeAllAnimations];
    [RACObserve([PLCSelectedMapCache sharedInstance], selectedMap) subscribeNext:^(PLCMap *map) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.maps indexOfObject:map] inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.view.layer.allowsGroupOpacity = YES;
}

- (CGFloat)tableView:(__unused UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[self viewModelAtIndexPath:indexPath] rowHeight];
}

- (NSInteger)tableView:(__unused UITableView *)tableView numberOfRowsInSection:(__unused NSInteger)section {
    return self.calculator.rows.count;
}

- (IBAction)dismiss:(__unused id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)newMap:(__unused id)sender {
    UIAlertController *controller =
        [UIAlertController alertControllerWithTitle:@"New Map" message:@"Type a name for your map." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *createMapAction = [UIAlertAction actionWithTitle:@"Create Map"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(__unused UIAlertAction *action1) {
       PLCMap *map = [PLCMapStore createMapWithName:[controller.textFields[0] text]];
       NSMutableArray *mutable = [self.maps mutableCopy];
       [mutable insertObject:map atIndex:[self indexForMap:map]];
       self.maps = [mutable copy];
                                                       [PLCSelectedMapCache sharedInstance].selectedMap = map;
                                                       [self dismiss:nil];
                                                       
                                                   }];
    createMapAction.enabled = NO;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(__unused UIAlertAction *action){}];
    [controller addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textField.placeholder = NSLocalizedString(@"Ex. My Favorite Restaurants", nil);
        [textField.rac_textSignal subscribeNext:^(NSString *text) {
            createMapAction.enabled = ![text isEqualToString:@""];
        }];
    }];
    [controller addAction:cancelAction];
    [controller addAction:createMapAction];
    [self presentViewController:controller animated:YES completion:nil];
}

- (NSInteger)indexForMap:(PLCMap *)map {
    NSComparator comparator = ^NSComparisonResult(PLCMap *obj1, PLCMap *obj2) {
        return [obj1.name caseInsensitiveCompare:obj2.name];
    };
    NSInteger i = [self.maps indexOfObject:map
                             inSortedRange:(NSRange){0, self.maps.count}
                                   options:NSBinarySearchingInsertionIndex
                           usingComparator:comparator];
    return i;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PLCMapSelectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLCMapSelectionTableCellReuseIdentifier" forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(PLCMapSelectionTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell configureWithViewModel:[self viewModelAtIndexPath:indexPath]];
    cell.cellDelegate = self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PLCMap *map = self.maps[indexPath.row];
    [PLCSelectedMapCache sharedInstance].selectedMap = map;
    [self dismiss:nil];
}

- (IBAction)toggleCellDetail:(UIButton *)sender {
    sender.selected = !sender.selected;
    CGPoint point = [self.tableView convertPoint:sender.center fromView:sender.superview];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    PLCMapRowViewModel *viewModel = [self viewModelAtIndexPath:indexPath];
    viewModel.detailShown = !viewModel.detailShown;
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:0 animations:^{
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    } completion:nil];
}

#pragma mark - cell delegate

- (void)tableViewCellDidDelete:(PLCMapSelectionTableViewCell *)cell {
    if (self.maps.count == 1) {
        UIAlertController *controller =
        [UIAlertController alertControllerWithTitle:@"Can't delete last map" message:@"You have to have at least one map. To delete this map, make another map first." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action){}];
        [controller addAction:okAction];
        [self presentViewController:controller animated:YES completion:nil];
        return;
    }
    NSIndexPath *changedIndexPath = [self.tableView indexPathForCell:cell];
    PLCMap *map = self.maps[changedIndexPath.row];
    [PLCMapStore deleteMap:map];
    NSMutableArray *copy = [self.maps mutableCopy];
    [copy removeObject:map];
    self.maps = [copy copy];
}

- (PLCMapRowViewModel *)viewModelAtIndexPath:(NSIndexPath *)indexPath {
    PLCMap *map = self.maps[indexPath.row];
    PLCMapRowViewModel *viewModel = self.viewModels[[map uuid]];
    if (!viewModel) {
        viewModel = [[PLCMapRowViewModel alloc] initWithMap:map];
        self.viewModels[[map uuid]] = viewModel;
    }
    return viewModel;
}

- (IBAction)editMap:(UIButton *)sender {
    CGPoint point = [self.tableView convertPoint:sender.center fromView:sender.superview];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    PLCMap *map = self.maps[indexPath.row];
    UIAlertController *controller =
    [UIAlertController alertControllerWithTitle:@"Edit Name" message:@"Type a new name for your map." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *createMapAction = [UIAlertAction actionWithTitle:@"Rename"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(__unused UIAlertAction *action1) {
                                                                NSString *text = [controller.textFields[0] text];
                                                                [PLCMapStore updateMap:map withName:text];
                                                                self.maps =[ self.maps sortedArrayUsingComparator:^NSComparisonResult(PLCMap *obj1, PLCMap *obj2) {
                                                                    return [obj1.name caseInsensitiveCompare:obj2.name];
                                                                }];
                                                            }];
    createMapAction.enabled = NO;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(__unused UIAlertAction *action){}];
    [controller addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = map.name;
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textField.placeholder = NSLocalizedString(@"Ex. My Favorite Restaurants", nil);
        [textField.rac_textSignal subscribeNext:^(NSString *text) {
            createMapAction.enabled = ![text isEqualToString:@""];
        }];
    }];
    [controller addAction:cancelAction];
    [controller addAction:createMapAction];
    [self presentViewController:controller animated:YES completion:nil];

}

@end
