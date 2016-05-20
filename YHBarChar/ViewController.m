//
//  ViewController.m
//  YHBarChar
//
//  Created by zhouxf on 16/5/20.
//  Copyright © 2016年 busap. All rights reserved.
//

#import "ViewController.h"
#import "YHBarChartView.h"

@interface ViewController () <YHBarChartViewDelegate>
@property (weak, nonatomic) YHBarChartView *bcv;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 从当前月开始计算半年的月份
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MM";
    NSInteger month = [[df stringFromDate:[NSDate date]] integerValue];
    NSMutableArray *monthArray = [NSMutableArray arrayWithCapacity:6];
    for (NSInteger i = 0; i < 6; i++) {
        if (month <= 0) {
            month = 12;
        }
        [monthArray addObject:[NSString stringWithFormat:@"%ld月", (long)month]];
        month--;
    }
    
    YHBarChartView *bcv = [[YHBarChartView alloc] init];
    [self.view addSubview:bcv];
    self.bcv = bcv;
    bcv.delegate = self;
    bcv.frame = CGRectMake(10, 80, self.view.frame.size.width - 10 * 2, 280);
    bcv.xTitleArray = monthArray;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.bcv.vauleArray = @[@(80.52), @(60.52), @(200), @(100), @(30), @(50)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - YHBarChartViewDelegate
- (void)barChartView:(YHBarChartView *)barChartView didClickChartViewIndex:(NSInteger)index {
    NSLog(@"barChartView didClickChartViewIndex = %ld", (long)index);
}

@end
