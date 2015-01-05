//
//  PLCImageDownloader.m
//  Places
//
//  Created by Jack Flintermann on 9/24/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCImageDownloader.h"
#import <AFNetworking/AFHTTPRequestOperation.h>
#import <TMCache/TMCache.h>

@interface PLCImageDownloader()
@property(nonatomic) id<NSObject> observerCache;
@end

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

- (void)dealloc {
    [self reset];
}

- (void)addUrls:(NSArray *)urls completion:(PLCImageDownloadingHandler)completion {
    NSMutableArray *mutableUrls = [urls mutableCopy];
    NSMutableArray *images = [NSMutableArray array];
    for (NSURL *url in urls) {
        UIImage *cachedImage = [[TMCache sharedCache] objectForKey:url.absoluteString];
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
        [operation setCompletionBlockWithSuccess:^(__unused AFHTTPRequestOperation *completionOperation, id responseObject) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf.delegate imageDownloader:strongSelf didDownloadImage:responseObject atURL:url];
            [images addObject:responseObject];
            [[TMCache sharedCache] setObject:responseObject forKey:url.absoluteString];
            [mutableUrls removeObject:url];
            if (mutableUrls.count == 0) {
                completion(images);
            }
        } failure:^(__unused AFHTTPRequestOperation *failureOperation, __unused NSError *error) {
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
