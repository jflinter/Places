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
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PLCMapSelectionTableViewController () <SWTableViewCellDelegate, UITextFieldDelegate>
@end

@implementation PLCMapSelectionTableViewController

#pragma mark - Table view data source

- (void)viewDidLoad {
    [RACObserve(self, maps) subscribeNext:^(__unused id x) {
        [self.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar.layer removeAllAnimations];
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
                                                   handler:^(__unused UIAlertAction *action) {
                                                       PLCMap *map = [PLCMapStore createMapWithName:[controller.textFields[0] text]];
                                                       self.maps = [[self.maps arrayByAddingObject:map] sortedArrayUsingComparator:^NSComparisonResult(PLCMap *obj1, PLCMap *obj2) {
                                                           return [obj1.name caseInsensitiveCompare:obj2.name];
                                                       }];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PLCMapSelectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLCMapSelectionTableCellReuseIdentifier" forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(PLCMapSelectionTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell configureWithViewModel:[[PLCMapRowViewModel alloc] initWithMap:self.maps[indexPath.row]]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

@end
