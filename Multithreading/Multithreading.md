# Multithreading in iOS
iOS中的多线程编程

## Contents

- 多线程
- 开发经验
- NSThread
- GCD (Grand Central Dispatch)
- OperationQueue
- RunLoop
- Reference

## 多线程

为了避免在主线程中执行一些任务时可能会出现异常而卡死，我们可以把这些任务放到新的线程中进行执行，即使出现异常，主线程也依旧可以做取消操作的响应；同时，有时我们为了让用户拥有更好的体验，我们也常常把对界面、网络请求和应答等等的处理放到新的线程中进行，而不会因为有时很久的处理而让用户不能去操作其他只能够等待操作完成。

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
[myLock unLock];
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



## OperationQueue



## RunLoop



## Reference