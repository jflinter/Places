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

@interface PLCMapSelectionTableViewController () <PLCMapSelectionCellDelegate, UITextFieldDelegate>
@end

@implementation PLCMapSelectionTableViewController

#pragma mark - Table view data source

- (void)viewDidLoad {
    self.tableView.rowHeight = 44;
    RACSignal* signal = [self rac_valuesAndChangesForKeyPath:@keypath(self, maps)
                                                     options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                                                    observer:self];
    
    [signal subscribeNext:^(RACTuple* tuple) {
        // the changes dictionary is stored in the second propery of the RAC Tuple
        NSDictionary* changes = tuple.second;
        
        NSArray* oldArray = changes[NSKeyValueChangeOldKey];
        NSArray* newArray = changes[NSKeyValueChangeNewKey];
        
        [self.tableView beginUpdates];
        
        NSMutableArray* rowsToDelete = [NSMutableArray array];
        NSMutableArray* rowsToInsert = [NSMutableArray array];
        
        [oldArray enumerateObjectsUsingBlock:^(id old, NSUInteger idx, __unused BOOL *stop) {
            if (![newArray containsObject:old]) {
                [rowsToDelete addObject: [NSIndexPath indexPathForRow:idx inSection:0]];
            }
        }];
        
        [newArray enumerateObjectsUsingBlock:^(id new, NSUInteger idx, __unused BOOL *stop) {
            if (![oldArray containsObject:new]) {
                [rowsToInsert addObject: [NSIndexPath indexPathForRow:idx inSection:0]];
            }
        }];
        
        [self.tableView deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertRowsAtIndexPaths:rowsToInsert withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView endUpdates];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar.layer removeAllAnimations];
    [RACObserve([PLCSelectedMapCache sharedInstance], selectedMap) subscribeNext:^(PLCMap *map) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.maps indexOfObject:map] inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

- (NSInteger)tableView:(__unused UITableView *)tableView numberOfRowsInSection:(__unused NSInteger)section {
    return self.maps.count;
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
    [cell configureWithViewModel:[[PLCMapRowViewModel alloc] initWithMap:self.maps[indexPath.row]]];
    cell.cellDelegate = self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PLCMap *map = self.maps[indexPath.row];
    [PLCSelectedMapCache sharedInstance].selectedMap = map;
    [self dismiss:nil];
}

#pragma mark - cell delegate

- (void)tableViewCell:(PLCMapSelectionTableViewCell *)cell textDidChange:(NSString *)text {
    NSIndexPath *changedIndexPath = [self.tableView indexPathForCell:cell];
    NSMutableArray *newMaps = [self.maps mutableCopy];
    PLCMap *map = self.maps[changedIndexPath.row];
    [newMaps removeObject:map];
    self.maps = [newMaps copy];
    [PLCMapStore updateMap:map withName:text];
    [newMaps insertObject:map atIndex:[self indexForMap:map]];
    self.maps = [newMaps copy];
}

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

@end
