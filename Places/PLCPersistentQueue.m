//
//  PLCPersistentQueue.m
//  Places
//
//  Created by Jack Flintermann on 12/28/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPersistentQueue.h"
#import <Reachability/Reachability.h>

@interface PLCSavableOperation : NSOperation
+ (instancetype)operationWithWork:(id<PLCAsynchronousWork>)work uuid:(NSString *)uuid;
@property (nonatomic) BOOL plcIsExecuting, plcIsFinished;
@property (nonatomic) id<PLCAsynchronousWork> work;
@property (nonatomic) NSString *uuid;
@end

@interface PLCPersistentQueue ()
+ (NSURL *)fileUrlForUuid:(NSString *)uuid;
@property (nonatomic) NSOperationQueue *operationQueue;
@end

@implementation PLCPersistentQueue

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ sharedInstance = [self new]; });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.qualityOfService = NSQualityOfServiceBackground;
        _operationQueue.maxConcurrentOperationCount = 2;
        Reachability *reach = [Reachability reachabilityForInternetConnection];
        [_operationQueue setSuspended:reach.currentReachabilityStatus == NotReachable];
        reach.reachableBlock = ^(Reachability *reachability) { [self.operationQueue setSuspended:NO]; };
        reach.unreachableBlock = ^(Reachability *reachability) { [self.operationQueue setSuspended:YES]; };
        [reach startNotifier];
    }
    return self;
}

- (void)resume {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtURL:[self.class fileUrl] withIntermediateDirectories:YES attributes:nil error:nil];
    NSArray *contents =
        [fileManager contentsOfDirectoryAtURL:[self.class fileUrl] includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    for (NSURL *fileURL in contents) {
        [self addWork:[NSKeyedUnarchiver unarchiveObjectWithFile:fileURL.path]];
    }
}

+ (NSURL *)fileUrl {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    return [documentsURL URLByAppendingPathComponent:@"PLCPersistentQueue"];
}

+ (NSURL *)fileUrlForUuid:(NSString *)uuid {
    return [[[self fileUrl] URLByAppendingPathComponent:uuid] URLByAppendingPathExtension:@"plist"];
}

- (void)addWork:(id<PLCAsynchronousWork>)work {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    // archive the operation to a file
    NSURL *url = [self.class fileUrlForUuid:uuid];
    [NSKeyedArchiver archiveRootObject:work toFile:url.path];
    // start doing it
    PLCSavableOperation *saveableOp = [PLCSavableOperation operationWithWork:work uuid:uuid];
    [self.operationQueue addOperation:saveableOp];
    // when it's done, delete the file
}

@end

@implementation PLCSavableOperation

+ (instancetype)operationWithWork:(id<PLCAsynchronousWork>)work uuid:(NSString *)uuid {
    PLCSavableOperation *operation = [[PLCSavableOperation alloc] init];
    operation.work = work;
    operation.uuid = uuid;
    return operation;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)start {
    if ([self isCancelled]) {
        [self finish];
        return;
    }
    self.executing = YES;
    [self.work doWork:^(NSError *error) {
        if (error && ![Reachability reachabilityForInternetConnection].isReachable) {
            [[PLCPersistentQueue sharedInstance] addWork:self.work];
        } else {
            [[NSFileManager defaultManager] removeItemAtURL:[PLCPersistentQueue fileUrlForUuid:self.uuid] error:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{ [self finish]; });
    }];
}

- (void)finish {
    self.executing = NO;
    self.finished = YES;
}

- (BOOL)isFinished {
    return self.plcIsFinished;
}

- (BOOL)isExecuting {
    return self.plcIsExecuting;
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _plcIsExecuting = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _plcIsFinished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

@end
