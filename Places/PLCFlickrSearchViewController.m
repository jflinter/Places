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
#import "PLCImageDownloader.h"

@interface PLCFlickrSearchViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, PLCImageDownloaderDelegate>
@property(nonatomic, readwrite, strong)NSString *query;
@property (nonatomic, readwrite, assign) MKCoordinateRegion searchRegion;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) NSOperation *flickrOperation;
@property (strong, nonatomic) PLCImageDownloader *downloader;
@property (strong, nonatomic) NSMutableArray *thumbnails;
@property (strong, nonatomic) NSMutableDictionary *urlMap;
@property (strong, nonatomic) NSMutableDictionary *largeUrlMap;
@end

@implementation PLCFlickrSearchViewController

static NSString * const reuseIdentifier = @"Cell";

- (instancetype)initWithQuery:(NSString *)query region:(MKCoordinateRegion)region {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(50, 50);
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _query = query;
        _searchRegion = region;
        _thumbnails = [NSMutableArray array];
        _downloader = [PLCImageDownloader new];
        _downloader.delegate = self;
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
    [self.downloader reset];
    [self.thumbnails removeAllObjects];
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
        NSArray *dicts = response[@"photos"][@"photo"];
        if (dicts.count > 40) {
            dicts = [dicts subarrayWithRange:NSMakeRange(0, 40)];
        }
        self.urlMap = [NSMutableDictionary dictionary];
        self.largeUrlMap = [NSMutableDictionary dictionary];
        NSMutableArray *urls = [@[] mutableCopy];
        for (NSDictionary *dict in dicts) {
            PLCFlickrSearchResult *result = [PLCFlickrSearchResult resultWithResponse:dict];
            [urls addObject:result.thumbnailUrl];
            (self.urlMap)[result.thumbnailUrl] = result.photoUrl;
        }
        __weak typeof(self) weakself = self;
        [self.downloader addUrls:urls completion:^(__unused NSArray *images) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!weakself.thumbnails.count) {
                    weakself.searchBar.prompt = NSLocalizedString(@"0 images found", nil);
                }
                else if (weakself.thumbnails.count == 1) {
                    weakself.searchBar.prompt = NSLocalizedString(@"1 image found", nil);
                }
                else {
                    NSString *template = NSLocalizedString(@"%@ images found", nil);
                    weakself.searchBar.prompt = [NSString stringWithFormat:template, @(weakself.thumbnails.count)];
                }
            });
        }];
    }];
}

- (NSInteger)collectionView:(__unused UICollectionView *)collectionView numberOfItemsInSection:(__unused NSInteger)section {
    return (NSInteger)self.thumbnails.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PLCFlickrResultCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.imageView.image = self.thumbnails[(NSUInteger)indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PLCFlickrResultCollectionViewCell *cell = (PLCFlickrResultCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell.activityIndicator startAnimating];
    NSURL *url = self.largeUrlMap[indexPath];
    
    __weak typeof(self) weakself = self;
    self.searchBar.userInteractionEnabled = NO;
    self.collectionView.userInteractionEnabled = NO;
    [self.downloader addUrls:@[url] completion:^(NSArray *images) {
        UIImage *image = images[0];
        if (image) {
            [weakself.delegate controller:weakself didFinishWithImage:image];
            return;
        }
        weakself.searchBar.userInteractionEnabled = YES;
        weakself.collectionView.userInteractionEnabled = YES;
    }];
}

#pragma mark <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PLCFlickrResultCollectionViewCell *cell = (PLCFlickrResultCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    return cell.imageView.image != nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(__unused NSIndexPath *)indexPath {
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

- (void)searchBarCancelButtonClicked:(__unused UISearchBar *)searchBar {
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

#pragma mark <PLCImageDownloaderDelegate>

- (void)imageDownloader:(__unused PLCImageDownloader *)downloader
       didDownloadImage:(UIImage *)image
                  atURL:(NSURL *)url {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (image && url && self.urlMap[url]) {
            [self.thumbnails addObject:image];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(NSInteger)self.thumbnails.count - 1 inSection:0];
            self.largeUrlMap[indexPath] = self.urlMap[url];
            [self.collectionView insertItemsAtIndexPaths:@[indexPath]];

        }
    });
}

@end
