//
//  ViewController.m
//  Demo
//
//  Created by aoliday on 15/8/4.
//  Copyright (c) 2015年 aoliday. All rights reserved.
//

#import "ViewController.h"
#import "ZQCountDownView.h"
#import "QYKTimer.h"

@interface ViewController ()<ZQCountDownViewDelegate>
@property (strong, nonatomic)  ZQCountDownView *countDownView;
@property (strong, nonatomic)  ZQCountDownView *countDownView2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.countDownView];
    
    NSTimeInterval interval = [self getIntervalWithName:@"1"];
    [self.countDownView setCountDownTimeInterval:interval timerId:@"1"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.countDownView removeFromSuperview];
    self.countDownView = nil;
    NSTimeInterval interval = [self getIntervalWithName:@"1"];
    
    // 重新使用原来的
    [self.view addSubview:self.countDownView];
    [self.countDownView setCountDownTimeInterval:interval timerId:@"1"];
    
    // 创建个新的
    [self.view addSubview:self.countDownView2];
    [self.countDownView2 setCountDownTimeInterval:interval timerId:@"2"];
}

- (NSTimeInterval)getIntervalWithName:(NSString *)name {
    NSTimeInterval interval = [QYKTimer fetchIntervalWithName:name];
    if (interval <= 0) {
        interval = 10;//默认值
    }
    return interval;
}

- (void)countDownDidFinished:(ZQCountDownView *)view {
    if (self.countDownView == view) {
        [self.countDownView removeFromSuperview];
        self.countDownView = nil;
    }
    
    if (self.countDownView2 == view) {
        [self.countDownView2 removeFromSuperview];
        self.countDownView2 = nil;
    }
}

- (ZQCountDownView *)countDownView {
    if (!_countDownView) {
        _countDownView = [[ZQCountDownView alloc] initWithFrame:CGRectMake(100, 100, 235, 30)];
        _countDownView.circularCorner = YES;
        _countDownView.themeColor = [UIColor orangeColor];
        _countDownView.recoderTimeIntervalDidInBackground = YES;
        _countDownView.delegate = self;
    }
    return _countDownView;
}

- (ZQCountDownView *)countDownView2 {
    if (!_countDownView2) {
        _countDownView2 = [[ZQCountDownView alloc] initWithFrame:CGRectMake(100, 150, 235, 30)];
        _countDownView2.themeColor = [UIColor whiteColor];
        _countDownView2.textColor = [UIColor darkGrayColor];
        _countDownView2.textFont = [UIFont boldSystemFontOfSize:20];
        _countDownView2.colonColor = [UIColor whiteColor];
        _countDownView2.delegate = self;
    }
    return _countDownView2;
}

@end
