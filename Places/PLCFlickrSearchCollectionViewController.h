//
//  PLCFlickrSearchCollectionViewController.h
//  Places
//
//  Created by Jack Flintermann on 9/21/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKGeometry.h>

@class PLCFlickrSearchCollectionViewController;

@protocol PLCFlickrSearchCollectionViewControllerDelegate <NSObject>

- (void)controller:(PLCFlickrSearchCollectionViewController *)controller
didFinishWithImage:(UIImage *)image;

@end

@interface PLCFlickrSearchCollectionViewController : UICollectionViewController

- (id)initWithQuery:(NSString *)query region:(MKCoordinateRegion)region;
@property(nonatomic, readwrite, weak)id<PLCFlickrSearchCollectionViewControllerDelegate>delegate;

@end
