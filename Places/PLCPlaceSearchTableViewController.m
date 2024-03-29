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
#import "PLCSelectedMapCache.h"
#import "PLCPlaceStore.h"
#import "PLCPlace.h"

@interface PLCPlaceSearchTableViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSOperation *foursquareOperation;
@property (nonatomic) NSArray *searchResults;

@end

@implementation PLCPlaceSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar.prompt = NSLocalizedString(@"Search for nearby places to add", nil);
    self.searchBar.placeholder = NSLocalizedString(@"Ex. Statue of Liberty", nil);
    [self.tableView registerClass:[PLCPlaceSearchResultTableViewCell class] forCellReuseIdentifier:@"PLCPlaceSearchResultCellIdentifier"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.searchBar becomeFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(__unused UISearchBar *)searchBar {
    if (!self.searchBar.inputAccessoryView) {
        UIInputView *inputView = [[UIInputView alloc] initWithFrame:CGRectMake(0, 0, self.view.window.frame.size.width, 15) inputViewStyle:UIInputViewStyleKeyboard];
        CGRect rect = inputView.bounds;
        rect.origin.y = 6;
        UILabel *label = [[UILabel alloc] initWithFrame:rect];
        label.text = NSLocalizedString(@"Search powered by Foursquare", nil);
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"AvenirNext-Regular" size:12.0f];
        [inputView addSubview:label];
        self.searchBar.inputAccessoryView = inputView;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.searchResults = nil;
}

- (NSInteger)tableView:(__unused UITableView *)tableView numberOfRowsInSection:(__unused NSInteger)section {
    return (NSInteger)self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PLCPlaceSearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLCPlaceSearchResultCellIdentifier" forIndexPath:indexPath];
    PLCPlaceSearchResult *result = self.searchResults[(NSUInteger)indexPath.row];
    cell.textLabel.text = result.title;
    cell.detailTextLabel.text = result.addressString;
    return cell;
}

- (void)tableView:(__unused UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.foursquareOperation cancel];
    PLCPlaceSearchResult *result = self.searchResults[(NSUInteger)indexPath.row];
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:^{
                                                          PLCPlace *place = [PLCPlaceStore insertPlaceOntoMap:[PLCSelectedMapCache sharedInstance].selectedMap atCoordinate:result.coordinate];
                                                          place.caption = [result.title stringByAppendingString:@"\n"];
                                                      }];
}

- (void)searchBar:(__unused UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.foursquareOperation cancel];
    if (searchText.length >= 3) {
        void (^onComplete)(BOOL success, NSDictionary * result) = ^void(BOOL success, NSDictionary *foursquareResult) {
            if (success) {
                NSDictionary *response = [foursquareResult valueForKey:@"response"];
                NSArray *venues = [response valueForKey:@"minivenues"];
                NSMutableArray *results = [@[] mutableCopy];
                for (NSDictionary *dict in venues) {
                    PLCPlaceSearchResult *result = [[PLCPlaceSearchResult alloc] initWithResponseDict:dict];
                    [results addObject:result];
                }
                [self updateTableWithResults:[results copy]];
                switch (self.searchResults.count) {
                case 0:
                    self.searchBar.prompt = NSLocalizedString(@"No places found. Try moving the map?", nil);
                    break;
                case 1:
                    self.searchBar.prompt = NSLocalizedString(@"1 place found", nil);
                    break;
                default:
                    self.searchBar.prompt = [NSString stringWithFormat:NSLocalizedString(@"%i places found", nil), self.searchResults.count];
                    break;
                }
            } else {
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
                                                                           limit:@5
                                                                          radius:nil
                                                                               s:nil
                                                                               w:nil
                                                                               n:nil
                                                                               e:nil
                                                                        callback:onComplete];
    } else {
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
    [self.searchResults enumerateObjectsUsingBlock:^(PLCPlaceSearchResult *old, NSUInteger idx, __unused BOOL *stop) {
        if (![newResults containsObject:old]) {
            [rowsToDelete addObject:[NSIndexPath indexPathForRow:(NSInteger)idx inSection:0]];
        }
    }];
    [newResults enumerateObjectsUsingBlock:^(PLCPlaceSearchResult *new, NSUInteger idx, __unused BOOL *stop) {
        if (![self.searchResults containsObject:new]) {
            [rowsToAdd addObject:[NSIndexPath indexPathForRow:(NSInteger)idx inSection:0]];
        }
    }];
    [self.tableView deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:rowsToAdd withRowAnimation:UITableViewRowAnimationFade];
    self.searchResults = newResults;
    [self.tableView endUpdates];
}

- (void)searchBarSearchButtonClicked:(__unused UISearchBar *)searchBar {
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.foursquareOperation cancel];
    [searchBar resignFirstResponder];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableView:(__unused UITableView *)tableView estimatedHeightForRowAtIndexPath:(__unused NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(__unused UITableView *)tableView heightForRowAtIndexPath:(__unused NSIndexPath *)indexPath {
    return 60;
}

@end
