//
//  YHBarChartView.m
//  YHBarChar
//
//  Created by zhouxf on 16/5/20.
//  Copyright © 2016年 busap. All rights reserved.
//

#import "YHBarChartView.h"
#import <QuartzCore/QuartzCore.h>

//颜色值处理
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define  UIColorFromRGBA(rgbValue,aalpha)   [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(float)aalpha]
#define COLOR(R, G, B) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]

// 默认绿色
#define DefaultGreenColor UIColorFromRGB(0x8ec43e)

@interface YHBarChartView ()
/**
 *  底部的标题label数组
 */
@property (strong, nonatomic) NSMutableArray *titleLabels;
/**
 *  柱状图view数组
 */
@property (strong, nonatomic) NSMutableArray *barViews;
/**
 *  上部的具体值label数组
 */
@property (strong, nonatomic) NSMutableArray *vauleLabels;
/**
 *  柱状图下面的线条数组
 */
@property (strong, nonatomic) NSMutableArray *barLines;
/**
 *  x轴
 */
@property (weak, nonatomic) UIView *xLine;
/**
 *  y轴
 */
@property (weak, nonatomic) UIView *yLine;
@end

@implementation YHBarChartView

#pragma mark - 懒加载
- (NSMutableArray *)titleLabels {
    if (!_titleLabels) {
        _titleLabels = [NSMutableArray array];
    }
    
    return _titleLabels;
}

- (NSMutableArray *)barViews {
    if (!_barViews) {
        _barViews = [NSMutableArray array];
    }
    
    return _barViews;
}

- (NSMutableArray *)vauleLabels {
    if (!_vauleLabels) {
        _vauleLabels = [NSMutableArray array];
    }
    
    return _vauleLabels;
}

- (NSMutableArray *)barLines {
    if (!_barLines) {
        _barLines = [NSMutableArray array];
    }
    
    return _barLines;
}

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefaultVaule];
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews {
    // 创建x轴
    UIView *xLine = [[UIView alloc] init];
    xLine.backgroundColor = self.lineColor;
    [self addSubview:xLine];
    self.xLine = xLine;
    
    // 创建y轴
    UIView *yLine = [[UIView alloc] init];
    yLine.backgroundColor = self.lineColor;
    [self addSubview:yLine];
    self.yLine = yLine;
}

/**
 *  设置相关属性的默认值
 */
- (void)setupDefaultVaule {
    self.showWithAnime = YES;
    self.barWidth = 18;
    self.fontSize = 12;
    self.barColor = DefaultGreenColor;
    self.lineColor = UIColorFromRGB(0xcccccc);
    self.xTitleArray = @[@"title1", @"title2", @"title3", @"title4", @"title5", @"title6"];
    self.showVaule = NO;
    self.vauleArray = @[@(0), @(0), @(0), @(0), @(0), @(0)];
    self.showVaule = YES;
    self.maxVaule = 100;
}

#pragma mark - function
- (void)setBarColor:(UIColor *)barColor {
    _barColor = barColor;
    
    // 设置柱状图的颜色
    for (UIView *barView in self.barViews) {
        barView.backgroundColor = barColor;
    }
    
    [self setNeedsLayout];
}

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    
    // 设置x轴和y轴的线条颜色
    self.xLine.backgroundColor = lineColor;
    self.yLine.backgroundColor = lineColor;
    // 设置柱状图下方的线条颜色
    for (UIView *line in self.barLines) {
        line.backgroundColor = lineColor;
    }
    
    [self setNeedsLayout];
}

- (void)setFontSize:(double)fontSize {
    _fontSize = fontSize;
    
    // 设置标题的字体
    for (UILabel *label in self.titleLabels) {
        label.font = [UIFont systemFontOfSize:fontSize];
    }
    
    // 设置值的字体
    for (UILabel *label in self.vauleLabels) {
        label.font = [UIFont systemFontOfSize:fontSize];
    }
    
    [self setNeedsLayout];
}

/**
 *  返回保留两位小数点，且小数后面最末尾为0时也省略
 */
- (NSString *)strtingFormateWithDouble:(double)doubleVaule {
    NSString *str = [NSString stringWithFormat:@"%.2f", doubleVaule]; // 四舍五入
    if (((NSInteger)(str.doubleValue * 100)) % 10 == 0) {
        if (((NSInteger)(str.doubleValue * 10)) % 10 == 0) {
            str = [NSString stringWithFormat:@"%.0f", doubleVaule];
        } else {
            str = [NSString stringWithFormat:@"%.1f", doubleVaule];
        }
    }
    
    return str;
}

- (void)setVauleArray:(NSArray *)vauleArray {
    _vauleArray = vauleArray;
    
    // 计算y轴最大值
    self.maxVaule = 0;
    for (NSNumber *no in vauleArray) {
        // 只允许NSNumber类型
        NSAssert([no isKindOfClass:[NSNumber class]], @"vauleArray is only allow NSNumber class");
        // 必须>=-1
        NSAssert(no.doubleValue >= -1, @"vauleArray number must >= -1");
        
        if (no.doubleValue > self.maxVaule) {
            self.maxVaule = no.doubleValue;
        }
    }
    
    // 创建需要的子控件
    for (NSInteger i = 0; i < vauleArray.count; i++) {
        NSNumber *vaule = vauleArray[i];
        if (i < self.barViews.count) {
            // 已经有的直接设置属性
            UILabel *vauleLabel = self.vauleLabels[i];
            if (!self.showVaule || vaule.integerValue < 0){
                vauleLabel.text = @"";
            } else {
                vauleLabel.text = [NSString stringWithFormat:@"￥%@", [self strtingFormateWithDouble:vaule.doubleValue]];
            }
            
            if (i < self.xTitleArray.count) {
                UILabel *titleLabel = self.titleLabels[i];
                titleLabel.text = self.xTitleArray[i];
            }
            continue;
        } else { // 没有就创建
            // 创建标题label
            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.font = [UIFont systemFontOfSize:self.fontSize];
            if (i < self.xTitleArray.count) {
                titleLabel.text = self.xTitleArray[i];
            }
            [self addSubview:titleLabel];
            [self.titleLabels addObject:titleLabel];
            
            // 创建柱状图上方的值label
            UILabel *vauleLabel = [[UILabel alloc] init];
            vauleLabel.font = [UIFont systemFontOfSize:self.fontSize];
            vauleLabel.textAlignment = NSTextAlignmentCenter;
            if (!self.showVaule || vaule.integerValue < 0){
                vauleLabel.text = @"";
            } else {
                vauleLabel.text = [NSString stringWithFormat:@"￥%@", [self strtingFormateWithDouble:vaule.doubleValue]];
            }
            [self addSubview:vauleLabel];
            [self.vauleLabels addObject:vauleLabel];
            
            // 创建柱状图
            UIView *barView = [[UIView alloc] init];
            barView.backgroundColor = self.barColor;
            [self addSubview:barView];
            [self.barViews addObject:barView];
            
            // 创建柱状图下方的线条
            UIView *barLine = [[UIView alloc] init];
            barLine.backgroundColor = self.lineColor;
            [self addSubview:barLine];
            [self.barLines addObject:barLine];
        }
    }
    
    // 隐藏多余的
    if (self.vauleArray.count < self.barViews.count) {
        for (NSInteger i = self.vauleArray.count; i < self.barViews.count; i++) {
            UIView *bv = self.barViews[i];
            bv.hidden = YES;
            UIView *tl = self.titleLabels[i];
            tl.hidden = YES;
            UIView *vl = self.vauleLabels[i];
            vl.hidden = YES;
            UIView *bl = self.barLines[i];
            bl.hidden = YES;
        }
    }
    
    [self setNeedsLayout];
}

- (void)setXTitleArray:(NSArray *)xTitleArray {
    _xTitleArray = xTitleArray;
    
    // 设置x标题label的文字
    for (NSInteger i = 0; i < xTitleArray.count; i++) {
        // 只允许NSString类型
        NSString *str = xTitleArray[i];
        NSAssert([str isKindOfClass:[NSString class]], @"xTitleArray is only allow NSString class");
        
        // 超过子控件数量之后不设置
        if (i >= self.titleLabels.count) {
            break;
        }
        
        // 设置标题文字
        UILabel *label = self.titleLabels[i];
        label.text = str;
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    
    // 计算x轴和y轴的frame
    UIFont *titleFont = [UIFont systemFontOfSize:self.fontSize];
    self.xLine.frame = CGRectMake(0, size.height - titleFont.lineHeight - 0.5, size.width, 0.5);
    self.yLine.frame = CGRectMake(0, 0, 0.5, size.height - titleFont.lineHeight);
    
    if (self.maxVaule <= 0) {
        self.maxVaule = 100;
    }
    
    if (self.vauleArray.count <= 0) {
        return;
    }
    
    CGFloat padding = size.width / self.vauleArray.count;
    for (NSInteger i = 0; i < self.vauleArray.count; i++) {
        // 计算柱状图下面的线条的frame
        UIView *line = self.barLines[i];
        line.frame = CGRectMake(padding / 2 + i * (padding + 0.5), self.xLine.frame.origin.y - 5, 0.5, 5);
        
        // 计算x轴下面的标题的frame
        UILabel *titleLabel = self.titleLabels[i];
        titleLabel.frame = CGRectMake(i * padding, CGRectGetMaxY(self.xLine.frame), padding, titleFont.lineHeight);
        
        // 计算柱状图的初始frame
        UIView *barView = self.barViews[i];
        barView.frame = CGRectMake(line.center.x - self.barWidth / 2, line.frame.origin.y - 5, self.barWidth, 0);
        
        // 计算柱状图上方的值的初始frame
        UILabel *vauleLabel = self.vauleLabels[i];
        vauleLabel.frame = CGRectMake(titleLabel.frame.origin.x, barView.frame.origin.y - titleFont.lineHeight, titleLabel.frame.size.width, titleFont.lineHeight);
        
        // 计算柱状图的动画最终frame
        NSNumber *vaule = self.vauleArray[i];
        if (vaule.doubleValue < 0) {
            continue;
        }
        
        CGRect barViewFrame = barView.frame;
        CGFloat maxHeight = barViewFrame.origin.y - titleFont.lineHeight;
        barViewFrame.size.height = vaule.doubleValue / self.maxVaule * maxHeight;
        barViewFrame.origin.y -= barViewFrame.size.height;
        
        // 计算柱状图上方的值的最终frame
        CGRect vauleLabelFrame = vauleLabel.frame;
        vauleLabelFrame.origin.y = barViewFrame.origin.y - vauleLabelFrame.size.height;
        
        // 执行动画
        if (self.showWithAnime) {
            [UIView animateWithDuration:1.0 animations:^{
                vauleLabel.frame = vauleLabelFrame;
                barView.frame = barViewFrame;
            } completion:^(BOOL finished) {
            }];
        } else {
            barView.frame = barViewFrame;
            vauleLabel.frame = vauleLabelFrame;
        }
    }
}

#pragma mark - event
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 代理需要响应触摸时处理
    if ([self.delegate respondsToSelector:@selector(barChartView:didClickChartViewIndex:)]) {
        // 取得抬起时的点
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        
        for (NSInteger i = 0; i < self.barViews.count; i++) {
            UIView *view = self.barViews[i];
            // 点在柱状图的内部时通知代理
            if (CGRectContainsPoint(view.frame, point)) {
//                NSLog(@"touch index = %ld", (long)i);
                [self.delegate barChartView:self didClickChartViewIndex:i];
                return;
            }
        }
    }
}

@end
