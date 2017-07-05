//
//  main.m
//  BWMultithreading
//
//  Created by BobWong on 2017/7/5.
//  Copyright © 2017年 BobWongStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWNSThread.h"
#import "BWGCD.h"
#import "BWOperationQueue.h"
#import "BWRunLoop.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        BWNSThread *demoNSThread = [BWNSThread new];
        [demoNSThread multithreading];
        
    }
    return 0;
}
