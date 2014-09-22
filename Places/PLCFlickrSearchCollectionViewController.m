//
//  PLCFlickrSearchCollectionViewController.m
//  Places
//
//  Created by Jack Flintermann on 9/21/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCFlickrSearchCollectionViewController.h"
#import "PLCFlickrSearchResult.h"
#import "PLCFlickrResultCollectionViewCell.h"
#import <FlickrKit/FlickrKit.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface PLCFlickrSearchCollectionViewController ()<UICollectionViewDelegateFlowLayout>
@property(nonatomic, readwrite, strong)NSString *query;
@property (nonatomic, readwrite, assign) MKCoordinateRegion searchRegion;
@property (nonatomic, readwrite, strong) NSArray *results;
@end

@implementation PLCFlickrSearchCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (id)initWithQuery:(NSString *)query region:(MKCoordinateRegion)region {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(50, 50);
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _query = query;
        _searchRegion = region;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    // Register cell classes
    [self.collectionView registerClass:[PLCFlickrResultCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];

    FKFlickrPhotosSearch *search = [FKFlickrPhotosSearch new];
    search.text = self.query;
    search.bbox = [NSString stringWithFormat:@"%f,%f,%f,%f",
                   self.searchRegion.center.longitude - self.searchRegion.span.longitudeDelta,
                   self.searchRegion.center.latitude - self.searchRegion.span.latitudeDelta,
                   self.searchRegion.center.longitude + self.searchRegion.span.longitudeDelta,
                   self.searchRegion.center.latitude + self.searchRegion.span.latitudeDelta
                   ];
    [[FlickrKit sharedFlickrKit] call:search completion:^(NSDictionary *response, NSError *error) {
        NSMutableArray *results = [NSMutableArray array];
        for (NSDictionary *dict in response[@"photos"][@"photo"]) {
            PLCFlickrSearchResult *result = [PLCFlickrSearchResult resultWithResponse:dict];
            [results addObject:result];
        }
        self.results = [results copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            if (!self.results.count) {
                [self.delegate controller:self didFinishWithImage:nil];
            }
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return (NSInteger)self.results.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PLCFlickrResultCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    PLCFlickrSearchResult *result = self.results[(NSUInteger)indexPath.row];
    [cell.imageView setImageWithURL:result.photoUrl];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PLCFlickrResultCollectionViewCell *cell = (PLCFlickrResultCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.delegate controller:self didFinishWithImage:cell.imageView.image];
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

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

@end
