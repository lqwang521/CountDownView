//
// Created by wlq on 2019-04-11.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    QYKTimerTypeDefault = 0,
    QYKTimerTypeCutDown = 1
} QYKTimerType;

typedef void(^QYKTimerBlock)(void);

@interface QYKTimer : NSObject

/// 普通定时器 返回TimerId
/// @param task 执行回调
/// @param start 从何时开始
/// @param interval 时间间隔
/// @param repeats 重复执行
/// @param async 是否异步执行
+ (NSString *)execTask:(QYKTimerBlock)task
                 start:(NSTimeInterval)start
              interval:(NSTimeInterval)interval
               repeats:(BOOL)repeats
                 async:(BOOL)async;

/// 基础定时器（最终执行方法）返回TimerId
/// @param task 执行回调
/// @param start 从何时开始
/// @param interval 时间间隔
/// @param repeats 重复执行
/// @param async  是否异步执行
/// @param name 唯一标识
/// @param type 类型（定时执行还是倒计时）
/// @param finishTask 完成回调
+ (NSString *)execTask:(QYKTimerBlock)task
                 start:(NSTimeInterval)start
              interval:(NSTimeInterval)interval
               repeats:(BOOL)repeats
                 async:(BOOL)async
                  name:(NSString *)name
                  type:(QYKTimerType)type
            finishTask:(QYKTimerBlock)finishTask;

/// 普通定时器-selector方式 返回TimerId
/// @param target 代理对象
/// @param selector 执行方法
/// @param start 从何时开始
/// @param interval 时间间隔
/// @param repeats 重复执行
/// @param async  是否异步执行
+ (NSString *)execTask:(id)target
              selector:(SEL)selector
                 start:(NSTimeInterval)start
              interval:(NSTimeInterval)interval
               repeats:(BOOL)repeats
                 async:(BOOL)async;

/// 重新设置倒计时执行和完成回调 返回Timer
/// @param name 唯一标识
/// @param invokeTask 执行block
/// @param finishTask 结束block
+ (dispatch_source_t)resetTimerTask:(NSString *)name
                     invokeTask:(QYKTimerBlock)invokeTask
                     finishTask:(QYKTimerBlock)finishTask;

/// 获取倒计时的时间
/// @param name 唯一标识
+ (NSTimeInterval)fetchIntervalWithName:(NSString *)name;

/// 取消定时任务
/// @param name 唯一标识
+ (void)cancelTask:(NSString *)name;

@end
