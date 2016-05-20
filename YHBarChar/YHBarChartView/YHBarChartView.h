//
//  YHBarChartView.h
//  YHBarChar
//
//  Created by zhouxf on 16/5/20.
//  Copyright © 2016年 busap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YHBarChartView;

@protocol YHBarChartViewDelegate <NSObject>

@optional
/**
 *  点击了图表中的柱状图
 *
 *  @param barChartView 柱状图图表view
 *  @param index        柱状图index
 */
- (void)barChartView:(YHBarChartView *)barChartView didClickChartViewIndex:(NSInteger)index;

@end

/**
 *  柱状图图表view
 */
@interface YHBarChartView : UIView
@property (weak, nonatomic) id<YHBarChartViewDelegate> delegate;
/**
 *  值数组:NSNumber,且不支持负数
 */
@property (strong, nonatomic) NSArray *vauleArray;
/**
 *  x轴的标题数组:NSString
 */
@property (strong, nonatomic) NSArray *xTitleArray;
/**
 *  最大值:默认为100，可不设置，自动设置为值数组中的最大值
 */
@property (assign, nonatomic) double maxVaule;
/**
 *  标题字体大小:默认12
 */
@property (assign, nonatomic) double fontSize;
/**
 *  柱状图的颜色：默认绿色
 */
@property (strong, nonatomic) UIColor *barColor;
/**
 *  线的颜色：默认灰色
 */
@property (strong, nonatomic) UIColor *lineColor;
/**
 *  动画显示:默认YES
 */
@property (assign, nonatomic) BOOL showWithAnime;
/**
 *  柱状图宽度:默认18
 */
@property (assign, nonatomic) CGFloat barWidth;
/**
 *  是否显示柱状图上方的值：默认显示
 */
@property (assign, nonatomic) BOOL showVaule;
@end
