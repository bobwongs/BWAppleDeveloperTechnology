//
//  BWNSThread.m
//  BWMultithreading
//
//  Created by BobWong on 2017/7/5.
//  Copyright © 2017年 BobWongStudio. All rights reserved.
//

#import "BWNSThread.h"

@interface BWNSThread()

@property (strong, nonatomic) NSThread *thread0;

@end

@implementation BWNSThread

- (void)multithreading {
//    self.thread0 = [[NSThread alloc] initWithTarget:self selector:@selector(threadSelector0) object:nil];
//    [self.thread0 start];
    
    [NSThread detachNewThreadSelector:@selector(threadSelector0) toTarget:self withObject:nil];
}

- (void)main {
    NSLog(@"main");
}

- (void)threadSelector0 {
    NSLog(@"current thread: %@", [NSThread currentThread]);
    NSLog(@"is main thread: %d", [NSThread isMainThread]);
    NSLog(@"is multi thread: %d", [NSThread isMultiThreaded]);
}

- (void)threadSelector1 {
    
}

- (void)threadSelector2 {
    
}

@end
