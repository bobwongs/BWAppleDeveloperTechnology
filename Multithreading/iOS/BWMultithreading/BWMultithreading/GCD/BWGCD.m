//
//  BWGCD.m
//  BWMultithreading
//
//  Created by BobWong on 2017/7/5.
//  Copyright © 2017年 BobWongStudio. All rights reserved.
//

#import "BWGCD.h"

@implementation BWGCD

- (void)multithreading {
    // Loading用的是ActivityIndicator
    // 状态表现描述，阻塞主线程：不出现Loading框或者Loading转动的时候卡主；不阻塞主线程：Loading框能正常显示和转动
    
//    [self timeConsumingOperation];  // 阻塞主线程
    
    // 不会阻塞主线程，异步在全局已有的并发队列中执行
    // 简单的多线程实现，优先选择此方式，不用自己创建新队列去实现多线程
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self timeConsumingOperation];
//    });
    
    // 不阻塞主线程，异步在已有的串行队列中执行
//    dispatch_queue_t serial_queue = dispatch_queue_create("com.bws.BWGCD.MySerialQueue", DISPATCH_QUEUE_SERIAL);
//    dispatch_async(serial_queue, ^{
//        [self timeConsumingOperation];
//    });
    
    // 不阻塞主线程，异步在已有的并发队列中执行
//    dispatch_queue_t concurrent_queue = dispatch_queue_create("com.bws.BWGCD.MyConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(concurrent_queue, ^{
//        [self timeConsumingOperation];
//    });
    
    // 这样也不会阻塞主线程，说明主队列和主线程不是同一概念的东西
    dispatch_async(dispatch_get_main_queue(), ^{
        [self timeConsumingOperation];
    });
    
    // 这样会有运行报错，不能这样使用
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        [self timeConsumingOperation];
//    });
}

- (void)timeConsumingOperation {
    int a = 0;
    while (a < 1000000) {
        a += 1;
        NSLog(@"a: %d", a);
    }
    
    // 执行完成，回到主线程刷新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        // Do something work
    });
}

@end
