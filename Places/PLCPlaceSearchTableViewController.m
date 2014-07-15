//
//  PLCPlaceSearchTableViewController.m
//  Places
//
//  Created by Jack Flintermann on 7/14/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPlaceSearchTableViewController.h"
#import <Foursquare-API-v2/Foursquare2.h>
#import "PLCPlaceSearchResult.h"
#import "PLCPlaceSearchResultTableViewCell.h"
#import "PLCPlaceStore.h"
#import "PLCPlace.h"

@interface PLCPlaceSearchTableViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSOperation *foursquareOperation;
@property (nonatomic) NSArray *searchResults;

@end

@implementation PLCPlaceSearchTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchBar.prompt = NSLocalizedString(@"Search for nearby places to add", nil);
    self.tableView.contentInset = ({
        UIEdgeInsets insets = self.tableView.contentInset;
        insets.top += CGRectGetHeight(self.searchBar.frame);
        insets;
    });
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:14.0f]];
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0f]];
    
    UIInputView *inputView = [[UIInputView alloc] initWithFrame:CGRectMake(0, 0, 320, 15) inputViewStyle:UIInputViewStyleKeyboard];
    CGRect rect = inputView.bounds;
    rect.origin.y = 6;
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.text = NSLocalizedString(@"Search powered by Foursquare", nil);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"AvenirNext-Regular" size:12.0f];
    [inputView addSubview:label];
    self.searchBar.inputAccessoryView = inputView;
    

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.searchResults = nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PLCPlaceSearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLCPlaceSearchResultCellIdentifier" forIndexPath:indexPath];
    PLCPlaceSearchResult *result = self.searchResults[(NSUInteger)indexPath.row];
    cell.nameLabel.text = result.title;
    cell.addressLabel.text = result.addressString;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.foursquareOperation cancel];
    PLCPlaceSearchResult *result = self.searchResults[(NSUInteger)indexPath.row];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        PLCPlace *place = [[PLCPlaceStore sharedInstance] insertPlaceAtCoordinate:result.coordinate];
        place.caption = result.title;
    }];
}

- (UIScrollView *)scrollView {
    return self.tableView;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.foursquareOperation cancel];
    if (searchText.length >= 3) {
        void (^onComplete)(BOOL success, NSDictionary *result) = ^void(BOOL success, NSDictionary *result) {
            if (success) {
                NSDictionary *response = [result valueForKey:@"response"];
                NSArray *venues = [response valueForKey:@"minivenues"];
                NSMutableArray *results = [@[] mutableCopy];
                for (NSDictionary *dict in venues) {
                    PLCPlaceSearchResult *result = [[PLCPlaceSearchResult alloc] initWithResponseDict:dict];
                    [results addObject:result];
                }
                [self updateTableWithResults:[results copy]];
                switch (self.searchResults.count) {
                    case 0:
                        self.searchBar.prompt = NSLocalizedString(@"No places found", nil);
                        break;
                    case 1:
                        self.searchBar.prompt = NSLocalizedString(@"1 place found", nil);
                        break;
                    default:
                        self.searchBar.prompt = [NSString stringWithFormat:NSLocalizedString(@"%i places found", nil), self.searchResults.count];
                        break;
                }
            }
            else {
                self.searchBar.prompt = NSLocalizedString(@"Error fetching nearby places", nil);
            }
        };
        self.foursquareOperation = [Foursquare2 venueSuggestCompletionByLatitude:@(self.searchRegion.center.latitude)
                                            longitude:@(self.searchRegion.center.longitude)
                                                 near:@""
                                           accuracyLL:nil
                                             altitude:nil
                                          accuracyAlt:nil
                                                query:searchText
                                                limit:@4
                                               radius:nil
                                                    s:nil
                                                    w:nil
                                                    n:nil
                                                    e:nil
                                             callback:onComplete];
    }
    else {
        self.searchBar.prompt = NSLocalizedString(@"Search for nearby places to add", nil);
        [self updateTableWithResults:@[]];
    }
}

- (void)updateTableWithResults:(NSArray *)newResults {
    [self.tableView beginUpdates];
    // added rows
    // deleted rows
    NSMutableArray *rowsToDelete = [@[] mutableCopy];
    NSMutableArray *rowsToAdd = [@[] mutableCopy];
    [self.searchResults enumerateObjectsUsingBlock:^(PLCPlaceSearchResult *old, NSUInteger idx, BOOL *stop) {
        if (![newResults containsObject:old]) {
            [rowsToDelete addObject:[NSIndexPath indexPathForRow:(NSInteger)idx inSection:0]];
        }
    }];
    [newResults enumerateObjectsUsingBlock:^(PLCPlaceSearchResult *new, NSUInteger idx, BOOL *stop) {
        if (![self.searchResults containsObject:new]) {
            [rowsToAdd addObject:[NSIndexPath indexPathForRow:(NSInteger)idx inSection:0]];
        }
    }];
    [self.tableView deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:rowsToAdd withRowAnimation:UITableViewRowAnimationFade];
    self.searchResults = newResults;
    [self.tableView endUpdates];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.foursquareOperation cancel];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
