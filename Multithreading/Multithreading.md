# Multithreading in iOS
iOS中的多线程编程

Github: https://github.com/bobwongs/BWAppleDeveloperTechnology

## Contents

- 多线程
- 开发经验
- NSThread
- GCD (Grand Central Dispatch)
- OperationQueue
- RunLoop
- Reference

## 多线程

通常，在iOS开发中，为了避免在主线程中执行一些复杂或者耗时的任务时可能会出现卡死，我们可以把这些任务放到新的线程中进行执行，在主线程中也依旧可以做取消操作的响应；同时，有时我们为了让用户拥有更好的体验，我们也常常把对界面、网络请求和应答等等的处理放到新的线程中进行，而不会因为有时很久的处理而让用户不能去操作其他只能够等待操作完成。

**原子性Atomicity**
你可能在属性声明时多次看到“nonatomic”。当你声明一个属性为原子性的，你通常用@synchronized block把它括起来，使它线程安全。当然，这个方法会增加些运行负载。

**iOS多线程实现技术对比**

Foundation 框架包含了一个名为 **NSThread** 类，它相对简单，但是使用它来管理多线程仍然是件头疼的事。

**GCD**是一种轻量级方式来描绘用以并发执行的工作单元。你不用计划这些工作单元；系统会为你计划好。在blocks中添加信赖会是一件头痛的事。作为一个开发者，取消或暂停一个代码块需要额处的工作量；

**NSOperation 和 NSOperationQueue** 是高层类，极大地简化了多线程的处理。**Operation queue** 提供了更多你在编写多线程程序时需要的功能，并隐藏了许多线程调度，线程取消与线程优先级的复杂代码，为我们提供简单的API入口。从编程原则来说，一般我们需要尽可能的使用高等级、封装完美的API，在必须时才使用底层API。但是我认为当我们的需求能够以更简单的底层代码完成的时候，简洁的GCD或许是个更好的选择，而Operation queue 为我们提供能更多的选择；NSOperation和NSOperationQueue相比于GCD，增加了一点额外开销，但你可以在不同的操作之间添加信赖。你可以重用操作，取消或挂起它们。NSOperation适合Key-Value Observation (KVO)；举例来说，你可以通过对NSNotificationCenter的监听来使一个NSOperation开始运行。

## 开发经验

网络请求、复杂数据的处理等等耗时或者影响用户体验的操作常常放在非主线程的线程上，避免主线程的堵塞；处理完成，则需要回到主线程进行UI的刷新，原因：避免多个线程同时刷新UI界面，造成不可预知的错误；

经验学习

- 多用派发队列，少用同步锁
  - 派发队列可用来表述同步语义（synchronization semantic），这种做法要比使用@synchronized块或NSLock对象更简单；
  - 将同步与异步派发结合起来，可以实现与普通加锁机制一样的同步行为，而这么做却不会阻塞执行异步派发的线程；
  - 使用同步队列及栅栏块，可以令同步行为更加高效；

在异步线程外部先对返回变量进行赋初始值，然后在线程里面进行返回变量的设值，然后又在方法末尾进行返回，其实此时返回的只会是原来的值，不会是新设置的值，所以不能过通过这种方式来返回值；还是得把操作写进线程里面，错误示例

```objective-c
- (NSInteger)maxNum {
  __block NSInteger num = 0;
  dispatchBlockSuccess:^{
    num = 5;
  }
  BlockFailure:^{
    num = 10;
  }
  return num;
}

// 此时的返回值可能一直都为0；因为对num的赋值是异步的，其执行会在return之后，所以不能通过这种方式进行返回值设置，更不能直接在Block里面进行返回；
```

## NSThread

优点：易理解，创建快；缺点：需要写很多相关方法，不便于代码的维护。

线程创建

```objective-c
-(id)init;
-(id)initWithTarget:(id)target selector:(SEL)selector object:(id)argument;
// 注：以上的两种方法创建线程之后需要手动启动，启动方法：-(void)start;

+ (void)detachNewThreadSelector:(SEL)aSelector toTarget:(id)aTarget withObject:(id)anArgument;
// 注：以上方法直接生产一个线程并启动它
```

iOS使用**NSCondition**来进行线程同步，它是iOS的锁对象，用来保护当前访问的资源

```objective-c
NSCondition *myLock = [[NSCondition alloc] init];
[myLock lock];
// 资源...
[myLock unlock];
```

**其他实用方法**

```objective-c
// 调用主线程的指定方法来执行相关操作
- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)wait;
// 判断是否为多线程
+ (BOOL)isMultiThreaded;
// 暂停当前线程
+ (void)sleepUntilDate:(NSDate *)date;
+ (void)sleepForTimeInterval:(NSTimeInterval)ti;
// 退出线程
+ (void)exit;
// 线程优先级
+ (double)threadPriority ;
+ (BOOL)setThreadPriority:(double)p ;
// 判断当前线程是否为主线程
- (BOOL)isMainThread;
+ (BOOL)isMainThread;
+ (NSThread *)mainThread;
// 是否在执行
- (BOOL)isExecuting;
// 是否已经结束
- (BOOL)isFinished;
// 是否取消的
- (BOOL)isCancelled;
// 取消操作
- (void)cancel;
// 线程启动
- (void)start;
- (void)main;    // thread body method
// 设置与返回线程名称
- (void)setName:(NSString *)n;
- (NSString *)name;
// 线程堆栈
- (NSUInteger)stackSize;
- (void)setStackSize:(NSUInteger)s;
```

## GCD (Grand Central Dispatch)

GCD是由语言特性，运行时库和系统增强包所提供的系统的和综合的提升，以支持在iOS和OS X上多核硬件上的并发；

GCD 是 libdispatch 的市场名称，而 libdispatch 作为 Apple 的一个库，为并发代码在多核硬件（跑 iOS 或 OS X ）上执行提供有力支持。它具有以下优点：

- GCD 能通过推迟昂贵计算任务并在后台运行它们来改善你的应用的响应性能；
- GCD 提供一个易于使用的并发模型而不仅仅只是锁和线程，以帮助我们避开并发陷阱；
- GCD 具有在常见模式（例如单例）上用更高性能的原语优化你的代码的潜在能力；

**Dispatch Queue相关术语**

> Main Queue：主队列，主队列不同于主线程，但是跟主线程紧密相关
>
> Global Queue：全局队列
>
> Serial Queue：串行队列，顺序执行队列中的Block，一个Block执行完之后，才会接着一个执行下一个Block
>
> Concurrent Queue：并发队列，并发执行队列中的Block，多个Block同时执行，执行的先后顺序取决于多线程实现的调度

**GCD实用操作**

**获得已存在的队列**

```objective-c
// Main Queue(Serial Queue)，主队列(串行队列)
dispatch_queue_t main_queue = dispatch_get_main_queue();

// Global Queue，全局队列，并发队列
// Returns a system-defined global concurrent queue with the specified quality of service class.
dispatch_queue_t global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY, 0);
```

**创建新队列**

```objective-c
// Serial Queue(Block is excuted one by one in the same queue.)
dispatch_queue_t serial_queue = dispatch_queue_create("com.bws.BWGCD.MySerialQueue", DISPATCH_QUEUE_SERIAL);

// Concurrent Queue(Block is excuted concurrent in the same queue.)
dispatch_queue_t concurrent_queue = dispatch_queue_create("com.bws.BWGCD.MyConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
```

**执行**

异步 dispatch_async

> Submits a block for asynchronous execution on a dispatch queue and returns immediately.
> This function is the fundamental mechanism for submitting blocks to a dispatch queue. Calls to this function always return immediately after the block has been submitted and never wait for the block to be invoked. The target queue determines whether the block is invoked serially or concurrently with respect to other blocks submitted to that same queue. Independent serial queues are processed concurrently with respect to each other.

同步 dispatch_sync

> Submits a block object for execution on a dispatch queue and waits until that block completes.
>
> Submits a block to a dispatch queue for synchronous execution. Unlike [dispatch_async](apple-reference-documentation://hcVyOLxquW), this function does not return until the block has finished. Calling this function and targeting the current queue results in deadlock. 
>
> Unlike with `dispatch_async`, no retain is performed on the target queue. Because calls to this function are synchronous, it "borrows" the reference of the caller. Moreover, no `Block_copy` is performed on the block.
>
> As an optimization, this function invokes the block on the current thread when possible.

示例

```
dispatch_async(queue, ^{
	// Do something
});
```

**其他**

```
dispatch_once
dispatch_after
等等
```

### OperationQueue

在Mac OS X v10.6和iOS 4之前，NSOperation与NSOperationQueue是不同于GCD的，采用的是两种不同的机制。从Mac OS X v10.6和iOS 4开始，NSOperation与NSOperationQueue是在GCD之上构建的。作为一个非常普遍的规则，Apple建议使用最高级别的抽象，然后当测量结果表明需要时才下降到较低层次的API。

**对比于GCD**

- 提供了在 GCD 中不那么容易复制的有用特性；

- 可以很方便的取消一个NSOperation的执行；

- 可以更容易的添加任务的依赖关系；

- 提供了任务的状态：isExecuteing, isFinished；

  说明：提到的 “任务”，“操作” 即代表要再NSOperation中执行的事情；

**NSOperation**

- NSInvocationOperation是NSOperation的子类；
- NSOperation是不能直接拿来调用的，使用其定义好的子类NSInvocationOperation或者自定义其子类重写main方法；

**实用操作**

```objective-c
NSOperationQueue *queue = [[NSOperationQueue alloc] init];
[queue addOperationWithBlock:^{
    [self timeConsumingOperation];  // Add operation with block
}];


// Block Operation
NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
    [self timeConsumingOperation];
}];
[blockOperation addExecutionBlock:^{
    // Do some thing
}];
[queue addOperation:blockOperation];


// Invocation Operation
NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(timeConsumingOperation) object:nil];
[queue addOperation:invocationOperation];


// Operation in main queue
[[NSOperationQueue mainQueue] addOperationWithBlock:^{
    [self timeConsumingOperation];
}];

// Other
queue.suspended = YES/NO;
[queue cancelAllOperations];
[operation cancel];
```

## RunLoop

待整理

## Reference

《Threading Programming Guide》

《Concurrency Programming Guide》