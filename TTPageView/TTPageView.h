//
//  TTPageView.h
//  Test
//
//  Created by niupark on 16/5/13.
//  Copyright © 2016年 niupark. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TTPageTopTabView;
@protocol TTPageViewSource;
@protocol TTPageViewDelegate;
/**
 *  @author LiuK, 16-05-13 15:05:41
 *
 *  TTPageView 分段选择控件
 *  TTPageView 有两种样式。如果allowContentView =NO不存在contentView则TTPageView类似UISegmentedControl
 * 如果allowContentView =YES ，存在contentView, 则TTPageView顶部是类似一个UISegmentedControl样式切换区域，
 * 高度根据topBarHeight确定，TTPageView剩余区域是contentView的区域
 */
IB_DESIGNABLE
@interface TTPageView : UIView
@property(nonatomic, assign)IBInspectable CGFloat topBarHeight;//顶部段选择视图的高度，缺省是50
// topBar宽高比 datasource设置未设置topbar的宽度，将按宽高比计算宽度,缺省是2:1
@property(nonatomic, assign)IBInspectable CGFloat AspectRatio; //暂时没用
@property(nonatomic, assign) CGFloat defaulIndex; //缺省选择第几个
//是否包含contentView， 如果包含内容View，如果包含，则topBar切换时，TTPageView的内容区域的View将会改变
@property(nonatomic, assign)IBInspectable BOOL allowContentView;
@property(nonatomic, strong)IBInspectable UIColor* underlineColor;
@property(nonatomic, strong)IBInspectable UIColor* selectlineColor;
@property(nonatomic, strong)IBInspectable UIColor* titileColor;

@property(nonatomic, readonly)NSInteger selectedIndex;

@property(nonatomic, weak)id<TTPageViewSource> dataSource;
@property(nonatomic, weak)id<TTPageViewDelegate> delegate;

@end


@protocol TTPageViewSource <NSObject>
//pageview top item的个数
-(NSInteger)numberOfCountInPageView:(TTPageView*)pageView;
@optional
//每一个barItem的宽带可定制
-(CGFloat)TTPageView:(TTPageView*)pageView WidthForBarAtIndex:(NSInteger)index;
//
-(void)TTPageView:(TTPageView*)pageView initTopTabView:(TTPageTopTabView*)topTabView atIndex:(NSInteger)index;

-(UIView*)contentViewForPageView:(TTPageView*)pageView atIndex:(NSInteger)index;
@end
@protocol TTPageViewDelegate <NSObject>

@optional
//top tab view created will call this selector
-(void)TTPageView:(TTPageView*)pageView didSelectAtIndex:(NSInteger)index topTabView:(TTPageTopTabView*)topTabView;
@end

@interface TTPageTopTabView : UIView
@property(nonatomic, readonly)NSInteger index;
@property(nonatomic, readonly)UILabel *titleLabel;
@property(nonatomic, assign)BOOL multiSelect; //是否支持多次选择，如果为YES，无论之前选择的是不是当前TTPageTopTabView都会触发TTPageView:didSelectAtIndex:topTabView:回调，否则不会触发，default NO

-(void)setSelected:(BOOL)selected;
@end
