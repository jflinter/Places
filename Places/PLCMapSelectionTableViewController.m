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

@interface PLCMapSelectionTableViewController()<SWTableViewCellDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate>
@end

@implementation PLCMapSelectionTableViewController

#pragma mark - Table view data source

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    [[PLCMapStore sharedInstance] registerDelegate:self];
}

- (void)dealloc {
    [[PLCMapStore sharedInstance] unregisterDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return (NSInteger)[[PLCMapStore sharedInstance] numberOfMaps];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 25.0f;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [UILabel new];
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.firstLineHeadIndent = 15.0f;
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-DemiBold" size:14.0f],
                                 NSParagraphStyleAttributeName: style,
                                 };
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Your Maps", nil) attributes:attributes];
    label.attributedText = string;
    label.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [tableView dequeueReusableCellWithIdentifier:@"PLCMapSelectionEditableCellReuseIdentifier" forIndexPath:indexPath];
    }
    PLCMapSelectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLCMapSelectionTableCellReuseIdentifier" forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(PLCMapSelectionTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return;
    }
    PLCMap *map = [[PLCMapStore sharedInstance] mapAtIndex:(NSUInteger)indexPath.row];
    cell.textLabel.text = map.name;
    cell.editTitleTextField.text = map.name;
    cell.editTitleTextField.alpha = 0;
    cell.editTitleTextField.hidden = YES;
    cell.editTitleTextField.delegate = self;
    cell.delegate = self;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor colorWithRed:131.0f/255.0f green:219.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
    [button setTitle:NSLocalizedString(@"Edit Title", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0f]];
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.backgroundColor = [UIColor colorWithRed:249.0f/255.0f green:58.0f/255.0f blue:47.0f/255.0f alpha:1.0f];
    [deleteButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deleteButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0f]];
    
    
    cell.rightUtilityButtons = @[button, deleteButton];
    if (map.selectedValue) {
        cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:18.0f];
    }
    else {
        cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18.0f];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section != 0) {
        [self performSegueWithIdentifier:@"PLCDidSelectMapSegue" sender:cell];        
    }
}

#pragma mark - SWTableViewCellDelegate

-(void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *indexPathForSelection = [self.tableView indexPathForCell:cell];
    [cell hideUtilityButtonsAnimated:YES];
    if (index == 0) {
        PLCMapSelectionTableViewCell *cast = (PLCMapSelectionTableViewCell *)cell;
        cast.editTitleTextField.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            cast.editTitleTextField.alpha = 1.0;
        } completion:^(BOOL finished) {
            [cast.editTitleTextField becomeFirstResponder];
        }];
        return;
    }
    PLCMapStore *mapStore = [PLCMapStore sharedInstance];
    if ([mapStore numberOfMaps] == 1) {
        [[[UIAlertView alloc] initWithTitle:@"Can't delete last map" message:@"You have to have at least one map. To delete this map, make another map first." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        return;
    }
    [mapStore deleteMapAtIndex:(NSUInteger)indexPathForSelection.row];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    [super prepareForSegue:segue sender:sender];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if (indexPath.section == 0) {
        self.navigationItem.backBarButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel new map back button item text");
        return;
    }
    if ([segue.identifier isEqualToString:@"PLCDidSelectMapSegue"]) {
        PLCMapStore *mapStore = [PLCMapStore sharedInstance];
        mapStore.selectedMap = [mapStore mapAtIndex:(NSUInteger)indexPath.row];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer velocityInView:self.tableView];
    return self.tableView.contentOffset.y <= 0 && point.y > 0;
}

#pragma mark - PLCScrollViewController
- (UIScrollView *)scrollView {
    return self.tableView;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
    newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:newIndexPath.section];
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(PLCMapSelectionTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] forRowAtIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length != 0) {
        CGPoint point = [textField convertPoint:textField.center toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
        PLCMap *map = [[PLCMapStore sharedInstance] mapAtIndex:(NSUInteger)indexPath.row];
        map.name = textField.text;
        [[PLCMapStore sharedInstance] save];
        [textField resignFirstResponder];
    }
    return NO;
}

@end
