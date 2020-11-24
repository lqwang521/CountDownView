//
// Created by wlq on 2019-04-11.
//

#import "QYKTimer.h"

@implementation QYKTimer

static NSMutableDictionary *timerCountDownMDic;
static NSMutableDictionary *timerMDic;
dispatch_semaphore_t qyk_semaphore;

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timerMDic = [NSMutableDictionary dictionary];
        timerCountDownMDic = [NSMutableDictionary dictionary];
        qyk_semaphore = dispatch_semaphore_create(1);
    });
}

/// 普通定时器 返回TimerId
+ (NSString *)execTask:(QYKTimerBlock)task
                 start:(NSTimeInterval)start
              interval:(NSTimeInterval)interval
               repeats:(BOOL)repeats
                 async:(BOOL)async {
    
    return [self execTask:task
                    start:start
                 interval:interval
                  repeats:repeats
                    async:async
                     name:nil
                     type:QYKTimerTypeDefault
               finishTask:nil];
}

/// 基础定时器（最终执行方法）返回TimerId
+ (NSString *)execTask:(QYKTimerBlock)task
                 start:(NSTimeInterval)start
              interval:(NSTimeInterval)interval
               repeats:(BOOL)repeats
                 async:(BOOL)async
                  name:(NSString *)name
                  type:(QYKTimerType)type
            finishTask:(QYKTimerBlock)finishTask

{
    if (!task || start < 0 || (interval <= 0 && repeats)) return nil;
    
    // 队列
    dispatch_queue_t queue = async ? dispatch_get_global_queue(0, 0) : dispatch_get_main_queue();
    
    // 创建定时器
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    NSTimeInterval delta = 0;
    if (QYKTimerTypeDefault == type) {
        delta = start;
    }
    // 设置时间
    dispatch_source_set_timer(timer,
                              dispatch_time(DISPATCH_TIME_NOW, delta * NSEC_PER_SEC),
                              interval * NSEC_PER_SEC, 0);
    
    
    dispatch_semaphore_wait(qyk_semaphore, DISPATCH_TIME_FOREVER);
    // 定时器的唯一标识
    if (nil == name || name.length <= 0) {
        name = [NSString stringWithFormat:@"%zd", timerMDic.count];
    }
    
    // 存放到字典中
    timerMDic[name] = timer;
    timerCountDownMDic[name] = @(start);
    dispatch_semaphore_signal(qyk_semaphore);
    
    // 设置回调
    dispatch_source_set_event_handler(timer, ^{
        task();
        
        dispatch_semaphore_wait(qyk_semaphore, DISPATCH_TIME_FOREVER);
        NSNumber *num = timerCountDownMDic[name];
        NSInteger value = [num integerValue] - 1;
        timerCountDownMDic[name] = @(value);
        dispatch_semaphore_signal(qyk_semaphore);
        if (value <= 0) {
            finishTask();
            [self cancelTask:name];
        }
        
        if (!repeats) { // 不重复的任务
            [self cancelTask:name];
        }
    });
    
    // 启动定时器
    dispatch_resume(timer);
    
    return name;
}

/// 普通定时器-selector方式 返回TimerId
+ (NSString *)execTask:(id)target selector:(SEL)selector start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async
{
    if (!target || !selector) return nil;
    
    return [self execTask:^{
        if ([target respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [target performSelector:selector];
#pragma clang diagnostic pop
        }
    }
                    start:start
                 interval:interval
                  repeats:repeats
                    async:async
                     name:nil
                     type:QYKTimerTypeDefault
               finishTask:nil];
}

/// 取消定时任务
+ (void)cancelTask:(NSString *)name
{
    if (name.length == 0) return;
    
    dispatch_semaphore_wait(qyk_semaphore, DISPATCH_TIME_FOREVER);
    
    dispatch_source_t timer = timerMDic[name];
    if (timer) {
        dispatch_source_cancel(timer);
        [timerMDic removeObjectForKey:name];
        [timerCountDownMDic removeObjectForKey:name];
    }
    
    dispatch_semaphore_signal(qyk_semaphore);
}

/// 重新设置倒计时执行和完成回调 返回Timer
+ (dispatch_source_t)resetTimerTask:(NSString *)name
                         invokeTask:(QYKTimerBlock)invokeTask
                         finishTask:(QYKTimerBlock)finishTask
{
    if (name.length == 0) return nil;
    
    dispatch_semaphore_wait(qyk_semaphore, DISPATCH_TIME_FOREVER);
    dispatch_source_t timer = timerMDic[name];
    dispatch_semaphore_signal(qyk_semaphore);
    
    if (timer) {
        // 设置回调
        dispatch_source_set_event_handler(timer, ^{
            invokeTask();
            
            dispatch_semaphore_wait(qyk_semaphore, DISPATCH_TIME_FOREVER);
            NSNumber *num = timerCountDownMDic[name];
            NSInteger value = [num integerValue] - 1;
            timerCountDownMDic[name] = @(value);
            dispatch_semaphore_signal(qyk_semaphore);
            if (value <= 0) {
                finishTask();
                [self cancelTask:name];
            }
        });
    }
    
    
    
    return timer;
}

/// 获取倒计时的时间
+ (NSTimeInterval)fetchIntervalWithName:(NSString *)name  {
    dispatch_semaphore_wait(qyk_semaphore, DISPATCH_TIME_FOREVER);
    NSNumber *num = timerCountDownMDic[name];
    NSTimeInterval value = [num integerValue];
    dispatch_semaphore_signal(qyk_semaphore);
    return value;
}

@end
