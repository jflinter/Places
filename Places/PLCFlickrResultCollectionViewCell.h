//
//  PLCFlickrResultCollectionViewCell.h
//  Places
//
//  Created by Jack Flintermann on 9/21/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLCFlickrResultCollectionViewCell : UICollectionViewCell
@property(nonatomic, weak, readonly)UIImageView *imageView;
- (void)setImageUrl:(NSURL *)url animated:(BOOL)animated;
@end
