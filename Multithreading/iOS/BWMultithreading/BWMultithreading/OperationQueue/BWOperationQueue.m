//
//  BWOperationQueue.m
//  BWMultithreading
//
//  Created by BobWong on 2017/7/5.
//  Copyright © 2017年 BobWongStudio. All rights reserved.
//

#import "BWOperationQueue.h"

@implementation BWOperationQueue

- (void)multithreading {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        [self timeConsumingOperation];
    }];


    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        [self timeConsumingOperation];
    }];
    [blockOperation addExecutionBlock:^{
        
    }];
    [queue addOperation:blockOperation];


//    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(timeConsumingOperation) object:nil];
//    [queue addOperation:invocationOperation];


//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        [self timeConsumingOperation];
//    }];
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////        queue.suspended = YES;
//        [blockOperation cancel];
////        [queue cancelAllOperations];
//        
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            queue.suspended = NO;
//        });
//        
////        [queue cancelAllOperations];
//        
//    });
}

- (void)timeConsumingOperation {
    int a = 0;
    while (a < 1000000) {
        a += 1;
        NSLog(@"a: %d", a);
    }
}

@end
