//
//  QPlayerMaskView.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/2/24.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import "QPlayerMaskView.h"
#import "QSlider.h"
#import "Masonry.h"
#import "PSPopListView.h"

//间隙
#define Padding        10
//顶部底部工具条高度
#define ToolBarHeight     40

@interface QPlayerMaskView ()<UITableViewDelegate, UITableViewDataSource>


@end

@implementation QPlayerMaskView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initViews];
        [self makeConstraints];
    }
    return self;
}
- (void)initViews{
    [self addSubview:self.topToolBar];
    [self addSubview:self.bottomToolBar];
    [self addSubview:self.loadingView];
    [self addSubview:self.failButton];
    [self.topToolBar addSubview:self.backButton];
    [self.bottomToolBar addSubview:self.playButton];
    [self.bottomToolBar addSubview:self.rateButton];
    [self.bottomToolBar addSubview:self.currentTimeLabel];
    [self.bottomToolBar addSubview:self.totalTimeLabel];
    [self.bottomToolBar addSubview:self.progress];
    [self.bottomToolBar addSubview:self.slider];
    self.topToolBar.backgroundColor    = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.40000f];
    self.bottomToolBar.backgroundColor = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.40000f];
}
#pragma mark - 约束
- (void)makeConstraints{
    //顶部工具条
    [self.topToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self);
        make.height.mas_equalTo(ToolBarHeight);
    }];
    //底部工具条
    [self.bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-20);
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self).offset(-15);
        make.height.mas_equalTo(40);
    }];
    //转子
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    //返回按钮
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(Padding);
        if (@available(iOS 11.0, *)) {
            make.left.mas_equalTo(self.mas_safeAreaLayoutGuideLeft).mas_offset(Padding);
        } else {
            make.left.mas_equalTo(Padding);
        }
        make.bottom.mas_equalTo(-Padding);
        make.width.mas_equalTo(self.backButton.mas_height);
    }];
    //播放按钮
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(Padding);
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.bottomToolBar.mas_safeAreaLayoutGuideLeft).offset(Padding);
        } else {
            make.left.equalTo(self.bottomToolBar).offset(Padding);
        }
        make.bottom.mas_equalTo(-Padding);
        make.width.mas_equalTo(self.playButton.mas_height);
    }];
    //倍速按钮
    [self.rateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomToolBar);
        if (@available(iOS 11.0, *)) {
            make.right.equalTo(self.bottomToolBar.mas_safeAreaLayoutGuideRight).mas_offset(-Padding);
        } else {
            make.right.equalTo(self.bottomToolBar).offset(-Padding);
        }
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(20);
    }];
    //当前播放时间
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.playButton.mas_right).mas_offset(Padding);
        make.width.mas_equalTo(45);
        make.centerY.mas_equalTo(self.bottomToolBar);
    }];
    //总时间
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.rateButton.mas_left).mas_offset(-Padding);
        make.width.mas_equalTo(45);
        make.centerY.mas_equalTo(self.bottomToolBar);
    }];
    //缓冲条
    [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.currentTimeLabel.mas_right).mas_offset(Padding).priority(50);
        make.right.mas_equalTo(self.totalTimeLabel.mas_left).mas_offset(-Padding);
        make.height.mas_equalTo(2);
        make.centerY.mas_equalTo(self.bottomToolBar);
    }];
    //滑杆
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.progress);
    }];
    //失败按钮
    [self.failButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];
}
#pragma mark -- 设置颜色
-(void)setProgressBackgroundColor:(UIColor *)progressBackgroundColor{
    _progressBackgroundColor = progressBackgroundColor;
    _progress.trackTintColor = progressBackgroundColor;
}
-(void)setProgressBufferColor:(UIColor *)progressBufferColor{
    _progressBufferColor        = progressBufferColor;
    _progress.progressTintColor = progressBufferColor;
}
-(void)setProgressPlayFinishColor:(UIColor *)progressPlayFinishColor{
    _progressPlayFinishColor      = progressPlayFinishColor;
    _slider.minimumTrackTintColor = _progressPlayFinishColor;
}

#pragma mark - 懒加载
//顶部工具条
- (UIView *) topToolBar{
    if (_topToolBar == nil){
        _topToolBar = [[UIView alloc] init];
        _topToolBar.userInteractionEnabled = YES;
    }
    return _topToolBar;
}
//底部工具条
- (UIView *) bottomToolBar{
    if (_bottomToolBar == nil){
        _bottomToolBar = [[UIView alloc] init];
        _bottomToolBar.userInteractionEnabled = YES;
        _bottomToolBar.layer.cornerRadius = 20;
        _bottomToolBar.clipsToBounds = YES;
    }
    return _bottomToolBar;
}
//转子
- (QRotateAnimationView *) loadingView{
    if (_loadingView == nil){
        _loadingView = [[QRotateAnimationView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_loadingView startAnimation];
    }
    return _loadingView;
}
//返回按钮
- (UIButton *) backButton{
    if (_backButton == nil){
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[UIImage imageNamed:@"QBackBtn"] forState:UIControlStateNormal];
        [_backButton setImage:[UIImage imageNamed:@"QBackBtn"] forState:UIControlStateHighlighted];
        [_backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}
//播放按钮
- (UIButton *) playButton{
    if (_playButton == nil){
        _playButton = [[UIButton alloc] init];
        [_playButton setImage:[UIImage imageNamed:@"QPlayBtn"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"QPauseBtn"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}
//倍速按钮
- (UIButton *) rateButton{
    if (_rateButton == nil){
        _rateButton = [[UIButton alloc] init];
        _rateButton.backgroundColor = [UIColor whiteColor];
        _rateButton.layer.cornerRadius = 10;
        _rateButton.titleLabel.font = [UIFont systemFontOfSize:10];
        [_rateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _rateButton.clipsToBounds = YES;
        [_rateButton setTitle:@"倍速" forState:UIControlStateNormal];
//        [_rateButton setImage:[UIImage imageNamed:@"play_rate"] forState:UIControlStateNormal];
//        [_rateButton setImage:[UIImage imageNamed:@"play_rate"] forState:UIControlStateSelected];
        [_rateButton addTarget:self action:@selector(rateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rateButton;
}
//当前播放时间
- (UILabel *) currentTimeLabel{
    if (_currentTimeLabel == nil){
        _currentTimeLabel                           = [[UILabel alloc] init];
        _currentTimeLabel.font                      = [UIFont systemFontOfSize:12];
        _currentTimeLabel.textColor                 = [UIColor whiteColor];
        _currentTimeLabel.adjustsFontSizeToFitWidth = YES;
        _currentTimeLabel.text                      = @"00:00";
        _currentTimeLabel.textAlignment             = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}
//总时间
- (UILabel *) totalTimeLabel{
    if (_totalTimeLabel == nil){
        _totalTimeLabel                           = [[UILabel alloc] init];
        _totalTimeLabel.font                      = [UIFont systemFontOfSize:12];
        _totalTimeLabel.textColor                 = [UIColor whiteColor];
        _totalTimeLabel.adjustsFontSizeToFitWidth = YES;
        _totalTimeLabel.text                      = @"00:00";
        _totalTimeLabel.textAlignment             = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}
//缓冲条
- (UIProgressView *) progress{
    if (_progress == nil){
        _progress = [[UIProgressView alloc] init];
    }
    return _progress;
}
//滑动条
- (QSlider *) slider{
    if (_slider == nil){
        _slider = [[QSlider alloc] init];
        // slider开始滑动事件
        [_slider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        // slider滑动中事件
        [_slider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        // slider结束滑动事件
        [_slider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        //右边颜色
        _slider.maximumTrackTintColor = [UIColor clearColor];
    }
    return _slider;
}
//加载失败按钮
- (UIButton *) failButton
{
    if (_failButton == nil) {
        _failButton        = [[UIButton alloc] init];
        _failButton.hidden = YES;
        [_failButton setTitle:@"加载失败,点击重试" forState:UIControlStateNormal];
        [_failButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _failButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        _failButton.backgroundColor = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.50000f];
        [_failButton addTarget:self action:@selector(failButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _failButton;
}
#pragma mark - 按钮点击事件
//返回按钮
- (void)backButtonAction:(UIButton *)button{
    if (_delegate && [_delegate respondsToSelector:@selector(cl_backButtonAction:)]) {
        [_delegate cl_backButtonAction:button];
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
}
//播放按钮
- (void)playButtonAction:(UIButton *)button{
    button.selected = !button.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(cl_playButtonAction:)]) {
        [_delegate cl_playButtonAction:button];
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
}
//倍速按钮
- (void)rateButtonAction:(UIButton *)button{
//    button.selected = !button.selected;
//    if (_delegate && [_delegate respondsToSelector:@selector(cl_rateButtonAction:)]) {
//        [_delegate cl_rateButtonAction:button];
//    }else{
//        NSLog(@"没有实现代理或者没有设置代理人");
//    }
    
    // 创建
    PSPopListView *popListView = [PSPopListView psPopListViewWithDataArray:@[@"0.5x", @"0.75x", @"1.0x", @"1.25x", @"1.5x",@"1.75x",@"2.0x"] frame:CGRectMake((SCREEN_W - 120)/2, (SCREEN_H - 160)/2, 120, 160)];
    popListView.block = ^(NSInteger index, NSString *titleName) {
        if (index == 2) {
            [self.rateButton setTitle:@"倍速" forState:UIControlStateNormal];
        } else {
            [self.rateButton setTitle:titleName forState:UIControlStateNormal];
        }
        NSLog(@"选中第%ld行: %@", index, titleName);
    };
    [[self topViewController].view addSubview:popListView];

}

- (UIViewController * )topViewController {
    UIViewController *resultVC;
    resultVC = [self recursiveTopViewController:[[UIApplication sharedApplication].windows.firstObject rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self recursiveTopViewController:resultVC.presentedViewController];
    }
    return resultVC;
}
- (UIViewController * )recursiveTopViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self recursiveTopViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self recursiveTopViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}
//失败按钮
- (void)failButtonAction:(UIButton *)button{
    self.failButton.hidden = YES;
    self.loadingView.hidden   = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(cl_failButtonAction:)]) {
        [_delegate cl_failButtonAction:button];
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
}
#pragma mark - 滑杆
//开始滑动
- (void)progressSliderTouchBegan:(QSlider *)slider{
    if (_delegate && [_delegate respondsToSelector:@selector(cl_progressSliderTouchBegan:)]) {
        [_delegate cl_progressSliderTouchBegan:slider];
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
}
//滑动中
- (void)progressSliderValueChanged:(QSlider *)slider{
    if (_delegate && [_delegate respondsToSelector:@selector(cl_progressSliderValueChanged:)]) {
        [_delegate cl_progressSliderValueChanged:slider];
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
}
//滑动结束
- (void)progressSliderTouchEnded:(QSlider *)slider{
    if (_delegate && [_delegate respondsToSelector:@selector(cl_progressSliderTouchEnded:)]) {
        [_delegate cl_progressSliderTouchEnded:slider];
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
}
@end
