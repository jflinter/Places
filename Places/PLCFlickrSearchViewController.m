//
//  PLCFlickrSearchViewController.m
//  Places
//
//  Created by Jack Flintermann on 9/22/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCFlickrSearchViewController.h"
#import <FlickrKit/FlickrKit.h>
#import "PLCFlickrSearchResult.h"
#import "PLCFlickrResultCollectionViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface PLCFlickrSearchViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>
@property(nonatomic, readwrite, strong)NSString *query;
@property (nonatomic, readwrite, assign) MKCoordinateRegion searchRegion;
@property (nonatomic, readwrite, strong) NSArray *results;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) NSOperation *flickrOperation;
@end

@implementation PLCFlickrSearchViewController

static NSString * const reuseIdentifier = @"Cell";

- (id)initWithQuery:(NSString *)query region:(MKCoordinateRegion)region {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(50, 50);
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _query = query;
        _searchRegion = region;
    }
    return self;
}

- (void)dealloc {
    [self.flickrOperation cancel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(5, 8, 5, 8);
    // Register cell classes
    [self.collectionView registerClass:[PLCFlickrResultCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [self performSearchWithQuery:self.query];
    [self enableSearchBar];
}

- (void)performSearchWithQuery:(NSString *)query {
    
    self.results = @[];
    [self.collectionView reloadData];
    self.searchBar.text = query;
    self.searchBar.prompt = NSLocalizedString(@"Searching for images...", nil);
    [self.flickrOperation cancel];
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
    
    FKFlickrPhotosSearch *search = [FKFlickrPhotosSearch new];
    search.text = query;
    search.bbox = [NSString stringWithFormat:@"%f,%f,%f,%f",
                   self.searchRegion.center.longitude - self.searchRegion.span.longitudeDelta,
                   self.searchRegion.center.latitude - self.searchRegion.span.latitudeDelta,
                   self.searchRegion.center.longitude + self.searchRegion.span.longitudeDelta,
                   self.searchRegion.center.latitude + self.searchRegion.span.latitudeDelta
                   ];
    self.flickrOperation = [[FlickrKit sharedFlickrKit] call:search completion:^(NSDictionary *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
            self.searchBar.prompt = NSLocalizedString(@"Error fetching images", nil);
            return;
        }
        NSMutableArray *results = [NSMutableArray array];
        NSArray *dicts = response[@"photos"][@"photo"];
        if (dicts.count > 40) {
            dicts = [dicts subarrayWithRange:NSMakeRange(0, 40)];
        }
        for (NSDictionary *dict in dicts) {
            PLCFlickrSearchResult *result = [PLCFlickrSearchResult resultWithResponse:dict];
            [results addObject:result];
        }
        self.results = [results copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!dicts.count) {
                self.searchBar.prompt = NSLocalizedString(@"0 images found", nil);
            }
            else if (dicts.count == 1) {
                self.searchBar.prompt = NSLocalizedString(@"1 image found", nil);
            }
            else {
                NSString *template = NSLocalizedString(@"%@ images found", nil);
                self.searchBar.prompt = [NSString stringWithFormat:template, @(dicts.count)];
            }
            [self.collectionView reloadData];
        });
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return (NSInteger)self.results.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PLCFlickrResultCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    PLCFlickrSearchResult *result = self.results[(NSUInteger)indexPath.row];
    [cell setImageUrl:result.thumbnailUrl animated:YES];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PLCFlickrResultCollectionViewCell *cell = (PLCFlickrResultCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.delegate controller:self didFinishWithImage:cell.imageView.image];
}

#pragma mark <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PLCFlickrResultCollectionViewCell *cell = (PLCFlickrResultCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    return cell.imageView.image != nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger cols = 3;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionViewLayout;
    CGFloat totalWidth = CGRectGetWidth(collectionView.frame);
    totalWidth -= (layout.minimumInteritemSpacing * (cols - 1));
    totalWidth -= collectionView.contentInset.left;
    totalWidth -= collectionView.contentInset.right;
    CGFloat width = totalWidth / cols;
    return CGSizeMake(width, width);
}

#pragma mark <UISearchBarDelegate>

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self performSearchWithQuery:searchBar.text];
    [self enableSearchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.delegate controller:self didFinishWithImage:nil];
}

- (void)enableSearchBar {
    UIView *subview = [self.searchBar.subviews firstObject];
    Class class = NSClassFromString(@"UINavigationButton");
    for (UIView *view in subview.subviews) {
        if ([view isKindOfClass:class]) {
            ((UIButton *)view).enabled = YES;
        }
    }
}

@end
