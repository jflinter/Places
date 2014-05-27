//
//  UIImage+Color.h
//  Grouper
//
//  Created by Jack Flintermann on 12/23/12.
//  Copyright (c) 2012 Grouper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color
               cornerRadius:(CGFloat) cornerRadius;

+ (UIImage *) imageWithColor:(UIColor *)color
                 borderColor:(UIColor*)borderColor
                cornerRadius:(CGFloat)cornerRadius;

+ (UIImage *) imageWithColor:(UIColor *)color
                 borderColor:(UIColor*)borderColor
                 borderWidth:(CGFloat)borderWidth
                cornerRadius:(CGFloat)cornerRadius;

+ (UIImage *) imageWithColor:(UIColor *)color
                 borderColor:(UIColor*)borderColor
                 borderWidth:(CGFloat)borderWidth
                cornerRadius:(CGFloat)cornerRadius
                 minimumSize:(CGSize)minimumSize;

+ (UIImage *) circularImageWithColor:(UIColor *)color
                         borderColor:(UIColor *)borderColor
                         borderWidth:(CGFloat)borderWidth
                                size:(CGSize)size;

+ (UIImage *) buttonImageWithColor:(UIColor *)color
                       borderColor:(UIColor *)borderColor
                      cornerRadius:(CGFloat)cornerRadius
                      borderHeight:(CGFloat)borderHeight
                          topInset:(CGFloat)topInset;


@end
