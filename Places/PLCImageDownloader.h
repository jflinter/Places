//
//  PLCImageDownloader.h
//  Places
//
//  Created by Jack Flintermann on 9/24/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLCImageDownloader;

typedef void (^PLCImageDownloadingHandler)(NSArray *images);

@protocol PLCImageDownloaderDelegate <NSObject>

- (void)imageDownloader:(PLCImageDownloader *)downloader
       didDownloadImage:(UIImage *)image
                  atURL:(NSURL *)url;

@end

@interface PLCImageDownloader : NSObject

@property(nonatomic, weak)id<PLCImageDownloaderDelegate> delegate;
- (void)addUrls:(NSArray *)urls completion:(PLCImageDownloadingHandler)completion;
- (void)reset;

@end
