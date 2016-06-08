//
//  TTPageView.m
//  Test
//
//  Created by niupark on 16/5/13.
//  Copyright © 2016年 niupark. All rights reserved.
//

#import "TTPageView.h"

#define BOTTOM_LINE_HEIGH 3 //底部线条高度为
//十六进制颜色值
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface TTPageView()<UIScrollViewDelegate>{
    UIScrollView *_topBarScrollView;
    ;
    UIScrollView *_contentScrollView;
    UIView *_lineBottom;
    UIView *_topTabBottomLine;
    CGFloat _topBarHeight;
    UIColor *_selectlineColor;
    UIColor *_underlineColor;
    NSInteger _selectIndex;
    
}
@property(nonatomic, assign)CGFloat pageWidth; //页面宽带
@property(nonatomic, strong)NSMutableArray *tapBarList;
@property(nonatomic, strong)NSMutableArray *contenViewList;

@property(nonatomic, weak)TTPageTopTabView *selecteTabView;
@end;

@interface TTPageTopTabView()<UIGestureRecognizerDelegate>{
    UITapGestureRecognizer  *_tapGesture;
    UILabel*_titleLabel;
    NSInteger _index;
}
@property(nonatomic, weak)id tapdelegate;
@property(nonatomic, strong)UIColor *selectColor;
@property(nonatomic, strong)UIColor *unSelectColor;
@property(nonatomic, strong)UIFont *titleFont;
@property(nonatomic, weak)TTPageView *pageView;
@property(nonatomic, assign)BOOL isSelected;
-(void)setIndex:(NSInteger)index;
@end


@implementation UIView (ExtensionForPageView)
- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}
@end


@implementation TTPageView
@synthesize selectlineColor = _selectlineColor;
@synthesize underlineColor = _underlineColor;
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [self commonInit];
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self commonInit];
    return self;
    
}
-(void)commonInit{
    //初始化
    _topBarHeight = 50.0f ; //缺省高度50
    _AspectRatio = 2.0f;
    _topBarScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _topBarScrollView.scrollEnabled = YES;
    _topBarScrollView.alwaysBounceHorizontal = YES;
    _topBarScrollView.showsHorizontalScrollIndicator = NO;
    _topBarScrollView.contentInset = UIEdgeInsetsZero;
    self.tapBarList = [NSMutableArray array];
    self.contenViewList = [NSMutableArray array];
    _selectIndex = -1;
    [self addSubview:_topBarScrollView];
}
-(void)loadData{
    if (self.dataSource && self.tapBarList.count == 0) {
        NSInteger topItemCount = [self.dataSource numberOfCountInPageView:self];
        CGFloat defaultWidth = topItemCount >0?[self width]/topItemCount:[self width];
        CGFloat xOffset = 0;
        for (NSInteger i =0; i < topItemCount; i++) {
            [self.contenViewList addObject:@0];
            CGFloat dWidth = defaultWidth;
            if ([self.dataSource respondsToSelector:@selector(TTPageView:WidthForBarAtIndex:)]) {
                dWidth = [self.dataSource TTPageView:self WidthForBarAtIndex:i];
            }
            TTPageTopTabView *tpView = [[TTPageTopTabView alloc] initWithFrame:CGRectMake(xOffset, 0, dWidth, self.topBarHeight-BOTTOM_LINE_HEIGH)];
            [tpView setIndex:i];
            tpView.selectColor = self.selectlineColor;
            tpView.unSelectColor = self.titileColor;
            tpView.pageView = self;
            if ([self.dataSource respondsToSelector:@selector(TTPageView:initTopTabView:atIndex:)]) {
                [self.dataSource TTPageView:self initTopTabView:tpView atIndex:i];
            }
            [self.tapBarList addObject:tpView];
            [_topBarScrollView addSubview:tpView];
            xOffset += dWidth;
        }
        _topBarScrollView.contentSize = CGSizeMake(xOffset, 0);
        //创建tabTop下方总览线
        _topTabBottomLine = [UIView new];
        _topTabBottomLine.frame = CGRectMake(0, [_topBarScrollView height]-BOTTOM_LINE_HEIGH, xOffset, BOTTOM_LINE_HEIGH);
        _topTabBottomLine.backgroundColor = self.underlineColor;
        [_topBarScrollView addSubview:_topTabBottomLine];
        //创建选中移动线
        _lineBottom = [UIView new];
        _lineBottom.backgroundColor = self.selectlineColor;
        TTPageTopTabView * topTabView = [self.tapBarList objectAtIndex:self.defaulIndex];
        _lineBottom.frame = CGRectMake(topTabView.frame.origin.x, [_topBarScrollView height]-BOTTOM_LINE_HEIGH, topTabView.frame.size.width, BOTTOM_LINE_HEIGH);
        [_topBarScrollView addSubview:_lineBottom];
        [self selectTopBarAtIndex:self.defaulIndex];
    }
}
-(UIColor*)selectlineColor{
    if (_selectlineColor) {
        return _selectlineColor;
    }else {
        return UIColorFromRGB(0xff6262);
    }
}
-(UIColor*)underlineColor{
    if (_underlineColor) {
        return _underlineColor;
    }else {
        return UIColorFromRGB(0xE5E5E5);
    }
}
-(UIColor*)titileColor{
    if (_titileColor) {
        return _titileColor;
    }else {
        return [UIColor grayColor];
    }
}
-(void)CreatecontentScrollView{
    if (!_contentScrollView && self.dataSource) {
        _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.topBarHeight,0,0)];
        _contentScrollView.delegate = self;
        _contentScrollView.backgroundColor = [UIColor clearColor];
        NSInteger topItemCount = [self.dataSource numberOfCountInPageView:self];
        _contentScrollView.contentSize = CGSizeMake(topItemCount * self.frame.size.width, 0);
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.alwaysBounceHorizontal = YES;
        [self addSubview:_contentScrollView];
    }
}
#pragma scrallview delegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView == _contentScrollView) {
        NSInteger index = ((NSInteger)(targetContentOffset->x /self.pageWidth));
        [self selectTopBarAtIndex:index];
    }
}
-(NSInteger)selectedIndex{
    return _selectIndex;
}
-(void)setDefaulIndex:(CGFloat)defaulIndex{
    _defaulIndex = defaulIndex;
    [self selectTopBarAtIndex:defaulIndex];
}
//选中
-(void)selectTopBarAtIndex:(NSInteger)index{
    if (index < 0 || index >self.tapBarList.count-1) {
        return;
    }
    TTPageTopTabView * topTabView = [self.tapBarList objectAtIndex:index];
    if (topTabView.multiSelect || self.selecteTabView != topTabView) {
        [self.selecteTabView setSelected:NO];
        [topTabView setSelected:YES];
        self.selecteTabView = topTabView;
        [UIView animateWithDuration:0.3 animations:^{
            _lineBottom.frame = CGRectMake(topTabView.frame.origin.x, [_topBarScrollView height]-BOTTOM_LINE_HEIGH, topTabView.frame.size.width, BOTTOM_LINE_HEIGH);
        }];
        if (self.delegate && [self.delegate respondsToSelector:@selector(TTPageView:didSelectAtIndex:topTabView:)]) {
            [self.delegate TTPageView:self didSelectAtIndex:index topTabView:topTabView];
        }
        UIView *contenView = nil;
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(contentViewForPageView:atIndex:)]) {
            contenView = [self.dataSource contentViewForPageView:self atIndex:index];
        }
        if (contenView && contenView != [self.contenViewList objectAtIndex:index]) { //添加过就不添加了
            UIView  *view = [self.contenViewList objectAtIndex:index];
            if ([view isKindOfClass:[UIView class]]) {
                [view removeFromSuperview];
            }
            [self.contenViewList replaceObjectAtIndex:index withObject:contenView];
            contenView.frame = CGRectMake(self.pageWidth*index, 0, self.pageWidth , [_contentScrollView height]);
            [_contentScrollView addSubview:contenView];
        }
        
    }
    _selectIndex = index;
    [_contentScrollView setContentOffset:CGPointMake(index*self.pageWidth, 0)];
}
-(void)setAllowContentView:(BOOL)allowContentView{
    _allowContentView = allowContentView;
    [self setNeedsLayout];
}
-(void)setUnderlineColor:(UIColor *)underlineColor{
    _topTabBottomLine.backgroundColor = underlineColor;
    _underlineColor =underlineColor;
}
-(void)setSelectlineColor:(UIColor *)selectlineColor{
    _lineBottom.backgroundColor = selectlineColor;
    _selectlineColor =selectlineColor;
    
}

-(void)layoutSubviews{
    [self updateSubViewFrame];
    self.pageWidth = [self width];
    if (self.allowContentView) {
        [self CreatecontentScrollView];
    }
    [self loadData];
}
-(void)updateContentView{
    [_contentScrollView setHeight:[self height]-self.topBarHeight];
    [_contentScrollView setWidth:[self width]];
    for (NSInteger i =0; i < self.contenViewList.count; i++) {
        UIView *contenView = [self.contenViewList objectAtIndex:i];
        if([contenView isKindOfClass:[UIView class]]){
            contenView.frame = CGRectMake(self.pageWidth*i, 0, self.pageWidth , [_contentScrollView height]);
        }
    }
    
}
-(void)updateTobarViewFrame{
    CGFloat defaultWidth = self.tapBarList.count >0?[self width]/self.tapBarList.count:[self width];
    CGFloat xOffset = 0;
    for (NSInteger i =0; i < self.tapBarList.count; i++) {
        TTPageTopTabView *tpView = self.tapBarList[i];
        CGFloat dWidth = defaultWidth;
        if ([self.dataSource respondsToSelector:@selector(TTPageView:WidthForBarAtIndex:)]) {
            dWidth = [self.dataSource TTPageView:self WidthForBarAtIndex:i];
        }
        tpView.frame =CGRectMake(xOffset, 0, dWidth, self.topBarHeight-BOTTOM_LINE_HEIGH);
        xOffset += dWidth;
    }
    if (self.tapBarList.count > 0) {
        _topBarScrollView.contentSize = CGSizeMake(xOffset, 0);
        //创建tabTop下方总览线
        _topTabBottomLine.frame = CGRectMake(0, [_topBarScrollView height]-BOTTOM_LINE_HEIGH, xOffset, BOTTOM_LINE_HEIGH);
        //创建选中移动线
        TTPageTopTabView * topTabView = [self.tapBarList objectAtIndex:_selectIndex];
        _lineBottom.frame = CGRectMake(topTabView.frame.origin.x, [_topBarScrollView height]-BOTTOM_LINE_HEIGH, topTabView.frame.size.width, BOTTOM_LINE_HEIGH);
    }
    
}
-(void)updateSubViewFrame{
    [_topBarScrollView setHeight:self.topBarHeight];
    [_topBarScrollView setWidth:[self width]];
    [self updateContentView];
    [self updateTobarViewFrame];
}

-(void)setTopBarHeight:(CGFloat)topBarHeight{
    _topBarHeight = topBarHeight;
    [_topBarScrollView setHeight:self.topBarHeight];
}
//tapbar高度控制
-(CGFloat)topBarHeight{
    if (self.allowContentView) {
        return _topBarHeight;
    }else{
        return self.frame.size.height;
    }
}
//
-(void)setPageWidth:(CGFloat)pageWidth{
    _pageWidth = pageWidth;
}
@end
#pragma mark TTPageTopTabView implementation

@protocol TTPageTopTabViewDelegate <NSObject>

-(void)tapTTPageTopTabView:(TTPageTopTabView*)view;

@end

@implementation TTPageTopTabView
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _multiSelect =NO;
        self.backgroundColor = [UIColor clearColor];
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
        [_tapGesture setDelegate:self];
        [self addGestureRecognizer:_tapGesture];
    }
    return self;
}
-(UILabel*)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = self.unSelectColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        //        NSLayoutConstraint * left = [NSLayoutConstraint constraintWithItem:_titleFont attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0f];
        //                NSLayoutConstraint * top = [NSLayoutConstraint constraintWithItem:_titleFont attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0f];
        //                NSLayoutConstraint * right = [NSLayoutConstraint constraintWithItem:_titleFont attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0f];
        //                NSLayoutConstraint * buttom = [NSLayoutConstraint constraintWithItem:_titleFont attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0f];
        //         NSArray *constraints1=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_titleLabel]-|"
        //      options:0
        //                                　　　　　　　　　　　　　　　　　　　　　　　　　　　metrics:nil
        //                                 　　　　　　　　　　　　　　　　　　　　　　　　　　　views:NSDictionaryOfVariableBindings(button)];
        //        NSArray * constraints1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_titleLabel]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_titleLabel)];
        //        NSArray * constraints2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_titleLabel]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_titleLabel)];
        //        [self addConstraints:constraints1];
        //        [self addConstraints:constraints2];
        
        
        //        [self addConstraints:@[left, top, right, buttom]];
    }
    return _titleLabel;
}
-(void)layoutSubviews{
    _titleLabel.frame = self.bounds;
    
}
-(void)setIndex:(NSInteger)index{
    _index = index;
}
-(NSInteger)index{
    return _index;
}
-(UIColor*)unSelectColor{
    if (_unSelectColor) {
        return _unSelectColor;
    }
    return [UIColor grayColor];
}

-(UIColor*)selectColor{
    if (_selectColor) {
        return _selectColor;
    }
    return  UIColorFromRGB(0xff6262);
}
-(void)setFrame:(CGRect)frame{
    if (self.isSelected) {
        self.transform = CGAffineTransformMakeScale(1, 1);
    }
    [super setFrame:frame];
    if (self.isSelected) {
        self.transform = CGAffineTransformMakeScale(1.15, 1.15);
    };
}

-(void)setSelected:(BOOL)selected{
    self.titleLabel.textColor = selected ? self.selectColor:self.unSelectColor;
    self.isSelected = selected;
    if (selected) {
        [UIView animateWithDuration:0.3 animations:^{
            self.transform = CGAffineTransformMakeScale(1.15, 1.15);
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }
}
- (void)tapRecognized:(UITapGestureRecognizer*)gesture{
    [self.pageView selectTopBarAtIndex:self.index];
}

@end
