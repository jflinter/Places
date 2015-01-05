//
//  PLCFlickrSearchViewController.h
//  Places
//
//  Created by Jack Flintermann on 9/22/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKGeometry.h>

@class PLCFlickrSearchViewController;

@protocol PLCFlickrSearchViewControllerDelegate <NSObject>

- (void)controller:(PLCFlickrSearchViewController *)controller
didFinishWithImage:(UIImage *)image;

@end

@interface PLCFlickrSearchViewController : UIViewController

- (instancetype)initWithQuery:(NSString *)query region:(MKCoordinateRegion)region NS_DESIGNATED_INITIALIZER;
@property(nonatomic, readwrite, weak)id<PLCFlickrSearchViewControllerDelegate>delegate;

@end
