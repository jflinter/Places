//
//  PLCImageDownloader.m
//  Places
//
//  Created by Jack Flintermann on 9/24/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCImageDownloader.h"
#import <AFNetworking/AFHTTPRequestOperation.h>

@implementation PLCImageDownloader

+ (NSOperationQueue *)sharedImageRequestOperationQueue {
    static NSOperationQueue *_af_sharedImageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_sharedImageRequestOperationQueue = [[NSOperationQueue alloc] init];
        _af_sharedImageRequestOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });
    
    return _af_sharedImageRequestOperationQueue;
}

+ (NSCache *)sharedImageCache {
    static NSCache *cache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        cache = [[NSCache alloc] init];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [cache removeAllObjects];
        }];
    });
    return cache;
}

- (void)dealloc {
    [self reset];
}

- (void)addUrls:(NSArray *)urls completion:(PLCImageDownloadingHandler)completion {
    NSMutableArray *mutableUrls = [urls mutableCopy];
    NSMutableArray *images = [NSMutableArray array];
    for (NSURL *url in mutableUrls) {
        UIImage *cachedImage = [[[self class] sharedImageCache] objectForKey:url.absoluteString];
        if (cachedImage) {
            [self.delegate imageDownloader:self didDownloadImage:cachedImage atURL:url];
            [images addObject:cachedImage];
            [mutableUrls removeObject:url];
            if (mutableUrls.count == 0) {
                completion(images);
            }
            continue;
        }
        __weak __typeof(self)weakSelf = self;
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        operation.responseSerializer = [AFImageResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf.delegate imageDownloader:strongSelf didDownloadImage:responseObject atURL:url];
            [images addObject:responseObject];
            [[[strongSelf class] sharedImageCache] setObject:responseObject forKey:url.absoluteString];
            [mutableUrls removeObject:url];
            if (mutableUrls.count == 0) {
                completion(images);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [mutableUrls removeObject:url];
            if (mutableUrls.count == 0) {
                completion(images);
            }
        }];
        [[[self class] sharedImageRequestOperationQueue] addOperation:operation];
    }
}

- (void)reset {
    [[[self class] sharedImageRequestOperationQueue] cancelAllOperations];
}

@end