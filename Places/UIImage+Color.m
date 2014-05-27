//
//  UIImage+Color.m
//  Grouper
//
//  Created by Jack Flintermann on 12/23/12.
//  Copyright (c) 2012 Grouper. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color cornerRadius:(CGFloat) cornerRadius {
    return [self imageWithColor:color borderColor:color cornerRadius:cornerRadius];
}

+ (UIImage *) imageWithColor:(UIColor *)color borderColor:(UIColor*)borderColor cornerRadius:(CGFloat)cornerRadius {
    return [self imageWithColor:color borderColor:borderColor borderWidth:2.0 cornerRadius:cornerRadius];
}

+ (UIImage *) imageWithColor:(UIColor *)color borderColor:(UIColor*)borderColor borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius {
    CGSize size = CGSizeMake(cornerRadius * 2 + 1, cornerRadius * 2 + 1);
    return [self imageWithColor:color borderColor:borderColor borderWidth:borderWidth cornerRadius:cornerRadius minimumSize:size];
}

+ (UIImage *) imageWithColor:(UIColor *)color
                 borderColor:(UIColor*)borderColor
                 borderWidth:(CGFloat)borderWidth
                cornerRadius:(CGFloat)cornerRadius
                 minimumSize:(CGSize)minimumSize {
    
    CGRect rect = CGRectMake(0, 0, minimumSize.width, minimumSize.height);
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    roundedRect.lineWidth = borderWidth;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    [color setFill];
    [borderColor setStroke];
    [roundedRect addClip];
    [roundedRect fill];
    [roundedRect stroke];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGFloat insetSize = MAX(cornerRadius + 1, borderWidth);
    
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(insetSize, insetSize, insetSize, insetSize)];
    
}

+ (UIImage *) buttonImageWithColor:(UIColor *)color
                       borderColor:(UIColor *)borderColor
                      cornerRadius:(CGFloat)cornerRadius
                      borderHeight:(CGFloat)borderHeight
                          topInset:(CGFloat)topInset {
    
    UIImage *topImage = [self imageWithColor:color borderColor:nil borderWidth:0 cornerRadius:cornerRadius];
    UIImage *bottomImage = [self imageWithColor:borderColor borderColor:nil borderWidth:0 cornerRadius:cornerRadius];
    CGFloat totalHeight = topImage.size.height + borderHeight + topInset;
    CGRect topRect = CGRectMake(0, topInset, topImage.size.width, topImage.size.height);
    CGRect bottomRect = CGRectMake(0, topInset, bottomImage.size.width, totalHeight - topInset);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(topImage.size.width, totalHeight), NO, 0.0f);
    [bottomImage drawInRect:bottomRect];
    [topImage drawInRect:topRect];
    UIImage *buttonImage = UIGraphicsGetImageFromCurrentImageContext();
    return [buttonImage resizableImageWithCapInsets:UIEdgeInsetsMake(cornerRadius + topInset, cornerRadius, borderHeight + cornerRadius, cornerRadius)];
    
}

+ (UIImage *) circularImageWithColor:(UIColor *)color
                         borderColor:(UIColor *)borderColor
                         borderWidth:(CGFloat)borderWidth
                                size:(CGSize)size {

    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    [color setFill];
    [borderColor setStroke];
    CGContextSetLineWidth(context, borderWidth);
    CGRect drawingRect = CGRectMake(borderWidth, borderWidth, size.width - (borderWidth * 2), size.height - (borderWidth * 2));
    CGContextStrokeEllipseInRect(context, drawingRect);
    CGContextFillEllipseInRect(context, drawingRect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
