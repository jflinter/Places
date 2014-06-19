//
//  PLCMapSelectionTableViewController.m
//  Places
//
//  Created by Jack Flintermann on 5/23/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCMapSelectionTableViewController.h"
#import "PLCMapDetailViewController.h"
#import "PLCMap.h"
#import "PLCMapStore.h"

@implementation PLCMapSelectionTableViewController

#pragma mark - Table view data source

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)[[[PLCMapStore sharedInstance] allMaps] count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0f;
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
    if (indexPath.row == 0) {
        return [tableView dequeueReusableCellWithIdentifier:@"PLCMapSelectionEditableCellReuseIdentifier" forIndexPath:indexPath];
    }
    NSIndexPath *modifiedIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLCMapSelectionTableCellReuseIdentifier" forIndexPath:modifiedIndexPath];
    [self configureCell:cell forRowAtIndexPath:modifiedIndexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    PLCMap *map = [[PLCMapStore sharedInstance] mapAtIndex:(NSUInteger)indexPath.row];
    cell.textLabel.text = map.name;
    if (map == [[PLCMapStore sharedInstance] selectedMap]) {
        cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:18.0f];
    }
    else {
        cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18.0f];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    [super prepareForSegue:segue sender:sender];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if (indexPath.row == 0) {
        self.navigationItem.backBarButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel new map back button item text");
        return;
    }
    if ([segue.identifier isEqualToString:@"PLCDidSelectMapSegue"]) {
        PLCMapStore *mapStore = [PLCMapStore sharedInstance];
        mapStore.selectedMap = [mapStore mapAtIndex:(NSUInteger)indexPath.row - 1];
    }
    else {
        PLCMapStore *mapStore = [PLCMapStore sharedInstance];
        PLCMapDetailViewController *controller = (PLCMapDetailViewController *)segue.destinationViewController;
        controller.map = [mapStore mapAtIndex:(NSUInteger)indexPath.row - 1];;
        self.navigationItem.backBarButtonItem.title = NSLocalizedString(@"Maps", @"Cancel map detail back button item text");
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

@end
