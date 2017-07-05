//
//  BWNSThread.m
//  BWMultithreading
//
//  Created by BobWong on 2017/7/5.
//  Copyright © 2017年 BobWongStudio. All rights reserved.
//

#import "BWNSThread.h"

@interface BWNSThread()

@end

static int ticketCounts = 1000;

@implementation BWNSThread

- (void)multithreading {
    NSThread *thread0 = [[NSThread alloc] initWithTarget:self selector:@selector(threadSelector0) object:nil];
    thread0.threadPriority = 1.0;  // 0.0-1.0，1.0优先级最高
    [thread0 start];
//    [thread0 cancel];
    
    [NSThread detachNewThreadSelector:@selector(threadSelector1) toTarget:self withObject:nil];
    
    [NSThread detachNewThreadSelector:@selector(threadSelector2) toTarget:self withObject:nil];
}

- (void)threadSelector0 {
//    NSLog(@"current thread: %@", [NSThread currentThread]);
//    NSLog(@"is main thread: %d", [NSThread isMainThread]);
//    NSLog(@"is multi thread: %d", [NSThread isMultiThreaded]);
    
    while (ticketCounts > 0) {
        ticketCounts -= 1;
        NSLog(@"first thread minus ticket, remain: %d", ticketCounts);
        [NSThread sleepForTimeInterval:0.2];
    }
}

- (void)threadSelector1 {
    while (ticketCounts > 0) {
        ticketCounts -= 1;
        NSLog(@"second thread minus ticket, remain: %d", ticketCounts);
    }
}

- (void)threadSelector2 {
    while (ticketCounts > 0) {
        ticketCounts -= 1;
        NSLog(@"third thread minus ticket, remain: %d", ticketCounts);
    }
}

@end
