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

@interface PLCMapSelectionTableViewController () <SWTableViewCellDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate>
@property(nonatomic)id<NSObject>notificationCenterCache;
@end

@implementation PLCMapSelectionTableViewController

#pragma mark - Table view data source

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    self.title = NSLocalizedString(@"Your Maps", nil);
    [[PLCMapStore sharedInstance] registerDelegate:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.notificationCenterCache];
    [[PLCMapStore sharedInstance] unregisterDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar.layer removeAllAnimations];
}

- (NSInteger)tableView:(__unused UITableView *)tableView numberOfRowsInSection:(__unused NSInteger)section {
    return (NSInteger)[[PLCMapStore sharedInstance] numberOfMaps];
}

- (CGFloat)tableView:(__unused UITableView *)tableView estimatedHeightForRowAtIndexPath:(__unused NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(__unused UITableView *)tableView heightForRowAtIndexPath:(__unused NSIndexPath *)indexPath {
    return 44;
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
                                                       NSString *mapTitle = [controller.textFields[0] text];
                                                       PLCMapStore *store = [PLCMapStore sharedInstance];
                                                       store.selectedMap = [store insertMapWithName:mapTitle];
                                                       [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    createMapAction.enabled = NO;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(__unused UIAlertAction *action){}];
    [controller addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textField.placeholder = NSLocalizedString(@"Ex. My Favorite Restaurants", nil);
        self.notificationCenterCache = [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification
                                                          object:textField
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(__unused NSNotification *note) { createMapAction.enabled = ![textField.text isEqualToString:@""]; }];
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
    PLCMap *map = [[PLCMapStore sharedInstance] mapAtIndex:(NSUInteger)indexPath.row];
    cell.textLabel.text = map.name;
    cell.editTitleTextField.text = map.name;
    cell.editTitleTextField.alpha = 0;
    cell.editTitleTextField.hidden = YES;
    cell.editTitleTextField.delegate = self;
    cell.delegate = self;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor colorWithRed:131.0f / 255.0f green:219.0f / 255.0f blue:242.0f / 255.0f alpha:1.0f];
    [button setTitle:NSLocalizedString(@"Edit Title", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0f]];

    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.backgroundColor = [UIColor colorWithRed:249.0f / 255.0f green:58.0f / 255.0f blue:47.0f / 255.0f alpha:1.0f];
    [deleteButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deleteButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0f]];

    cell.rightUtilityButtons = @[button, deleteButton];
    if (map.selectedValue) {
        cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:18.0f];
    } else {
        cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18.0f];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PLCMapStore *mapStore = [PLCMapStore sharedInstance];
    mapStore.selectedMap = [mapStore mapAtIndex:(NSUInteger)indexPath.row];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *indexPathForSelection = [self.tableView indexPathForCell:cell];
    [cell hideUtilityButtonsAnimated:YES];
    if (index == 0) {
        PLCMapSelectionTableViewCell *cast = (PLCMapSelectionTableViewCell *)cell;
        cast.editTitleTextField.hidden = NO;
        [UIView animateWithDuration:0.3
            animations:^{ cast.editTitleTextField.alpha = 1.0; }
            completion:^(__unused BOOL finished) { [cast.editTitleTextField becomeFirstResponder]; }];
        return;
    }
    PLCMapStore *mapStore = [PLCMapStore sharedInstance];
    if ([mapStore numberOfMaps] == 1) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Can't delete last map", nil)
                                    message:NSLocalizedString(@"You have to have at least one map. To delete this map, make another map first.", nil)
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        return;
    }
    [mapStore deleteMapAtIndex:(NSUInteger)indexPathForSelection.row];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(__unused NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(__unused NSFetchedResultsController *)controller
    didChangeObject:(__unused id)anObject
        atIndexPath:(NSIndexPath *)unmodifiedIndexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)unModifiedNewIndexPath {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:unmodifiedIndexPath.row inSection:unmodifiedIndexPath.section];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:unModifiedNewIndexPath.row inSection:unModifiedNewIndexPath.section];

    switch (type) {
    case NSFetchedResultsChangeInsert:
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        break;

    case NSFetchedResultsChangeDelete:
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        break;

    case NSFetchedResultsChangeUpdate:
        [self configureCell:(PLCMapSelectionTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] forRowAtIndexPath:indexPath];
        break;

    case NSFetchedResultsChangeMove:
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        break;
    }
}

- (void)controllerDidChangeContent:(__unused NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length != 0) {
        CGPoint point = [textField convertPoint:textField.center toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
        PLCMap *map = [[PLCMapStore sharedInstance] mapAtIndex:(NSUInteger)indexPath.row];
        [[PLCMapStore sharedInstance] updateMap:map withName:textField.text];
        [textField resignFirstResponder];
    }
    return NO;
}

@end
