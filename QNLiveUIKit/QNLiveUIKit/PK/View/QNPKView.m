//
//  QNPKView.m
//  QNLiveUIKit
//
//  Created by xiaodao on 2023/6/12.
//

#import "QNPKView.h"
#import <Masonry/Masonry.h>
#import "QNCountDownTimer.h"
#import "QNTimeFormatUtil.h"


#define kPKCountDownViewWidth 96
#define kPKCountDownViewHeight 20
#define kPKCountDownViewCorner 6
#define kPKScoreViewPadding 60

#pragma mark - QNPKCountDownType

//倒计时类型
typedef enum {
    QNPKCountDownTypePK,      //PK打榜阶段
    QNPKCountDownTypePenalty, //PK惩罚阶段
} QNPKCountDownType;


#pragma mark - QNPKCountDownView

/**
 PK倒计时视图
 */
@interface QNPKCountDownView: UIView

@property (nonatomic, strong) UILabel *countDownLabel;
//圆角
@property (nonatomic, strong) CAShapeLayer *bgLayer;

//更新视图（传入剩余时间，单位秒）
- (void)updateViewWithTime:(double)time countDownType:(QNPKCountDownType)countDownType;

@end

@implementation QNPKCountDownView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addBgLayer];
        [self addChilden];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Public Methods

//更新时间
- (void)updateViewWithTime:(double)time countDownType:(QNPKCountDownType)countDownType {
    NSString *title = (countDownType == QNPKCountDownTypePK) ? @"倒计时" : @"惩罚时间";
    self.countDownLabel.text = [NSString stringWithFormat:@"%@ %@", title, [QNTimeFormatUtil secondsToTime: time]];
}

#pragma mark - Private Methods

- (void)addBgLayer {
    self.bgLayer = [CAShapeLayer layer];
    self.bgLayer.fillColor = QNRGBA(0, 0, 0, 0.75).CGColor;
    [self.layer addSublayer:self.bgLayer];
}

- (void)addChilden {
    [self addSubview:self.countDownLabel];
}

- (void)setupConstraints {
    [self.countDownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(18);
        make.center.equalTo(self);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIBezierPath *leftPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(kPKCountDownViewCorner, kPKCountDownViewCorner)];
    self.bgLayer.path = leftPath.CGPath;
}

- (UILabel *)countDownLabel {
    if (!_countDownLabel) {
        _countDownLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countDownLabel.font = [UIFont systemFontOfSize:12];
        _countDownLabel.textColor = UIColor.whiteColor;
        _countDownLabel.text = @"倒计时 00:00";
    }
    return _countDownLabel;
}

@end


#pragma mark - QNPKScoreView

/**
 PK得分视图
 */
@interface QNPKScoreView: UIView

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;

@property (nonatomic, strong) UIView *leftBgView;
@property (nonatomic, strong) UIView *rightBgView;
//圆角
@property (nonatomic, strong) CAShapeLayer *leftBgLayer;
@property (nonatomic, strong) CAShapeLayer *rightBgLayer;

//分割滑块视图
@property (nonatomic, strong) UIView *dividerView;

//分割线位置约束
@property (nonatomic, weak) MASConstraint *dividerConstraint;

@end

@implementation QNPKScoreView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addChilden];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Public Methods

//更新分数
- (void)updateViewWithMyScore:(NSString *)myScore otherScore:(NSString *)otherScore {
    self.leftLabel.text = [NSString stringWithFormat:@"我方 %@", myScore];
    self.rightLabel.text = [NSString stringWithFormat:@"%@ 对方", otherScore];
    
    //根据分数变化，左右移动
    if (myScore && otherScore) {
        double myScoreNum = [myScore doubleValue];
        double otherScoreNum = [otherScore doubleValue];
        if (myScoreNum + otherScoreNum > 0) {
            self.dividerConstraint.offset = (myScoreNum / (myScoreNum + otherScoreNum) - 0.5) * (UIScreen.mainScreen.bounds.size.width * 0.65 - 8.0);
        }
    }
}

#pragma mark - Private Methods

- (void)addChilden {
    [self addSubview:self.leftBgView];
    [self addSubview:self.rightBgView];
    
    [self addSubview:self.leftLabel];
    [self addSubview:self.rightLabel];
    
    [self addSubview:self.dividerView];
}

- (void)setupConstraints {
    
    [self.leftBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self.dividerView.mas_left);
        make.height.mas_equalTo(18);
        make.top.equalTo(self);
    }];
    
    [self.rightBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.left.equalTo(self.dividerView.mas_right);
        make.height.mas_equalTo(18);
        make.top.equalTo(self);
    }];
    
    [self.dividerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(2);
        make.height.mas_equalTo(20);
        make.centerY.equalTo(self.leftBgView);
        //分割线位置约束
        self.dividerConstraint = make.centerX.equalTo(self);
    }];
    
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftBgView).offset(8);
        make.right.equalTo(self.leftBgView);
        make.centerY.equalTo(self.leftBgView);
    }];
    
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.rightBgView).offset(-8);
        make.left.equalTo(self.rightBgView);
        make.centerY.equalTo(self.rightBgView);
    }];
}

- (UILabel *)leftLabel {
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _leftLabel.font = [UIFont boldSystemFontOfSize:12];
        _leftLabel.textColor = UIColor.whiteColor;
        _leftLabel.text = @"我方";
    }
    return _leftLabel;
}

- (UILabel *)rightLabel {
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _rightLabel.font = [UIFont boldSystemFontOfSize:12];
        _rightLabel.textColor = UIColor.whiteColor;
        _rightLabel.textAlignment = NSTextAlignmentRight;
        _rightLabel.text = @"对方";
    }
    return _rightLabel;
}

- (UIView *)leftBgView {
    if (!_leftBgView) {
        _leftBgView = [[UIView alloc] initWithFrame:CGRectZero];
        //圆角
        self.leftBgLayer = [CAShapeLayer layer];
        self.leftBgLayer.fillColor = QNHEXCOLOR(0x6AB4F4).CGColor;
        [_leftBgView.layer addSublayer:self.leftBgLayer];
    }
    return _leftBgView;
}

- (UIView *)rightBgView {
    if (!_rightBgView) {
        _rightBgView = [[UIView alloc] initWithFrame:CGRectZero];
        //圆角
        self.rightBgLayer = [CAShapeLayer layer];
        self.rightBgLayer.fillColor = QNHEXCOLOR(0xD84D88).CGColor;
        [_rightBgView.layer addSublayer:self.rightBgLayer];
    }
    return _rightBgView;
}

- (UIView *)dividerView {
    if (!_dividerView) {
        _dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 20)];
        _dividerView.backgroundColor = UIColor.whiteColor;
        _dividerView.layer.cornerRadius = 1;
        _dividerView.clipsToBounds = YES;
    }
    return  _dividerView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIBezierPath *leftPath = [UIBezierPath bezierPathWithRoundedRect:self.leftBgView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(4, 4)];
    self.leftBgLayer.path = leftPath.CGPath;
    
    UIBezierPath *rightPath = [UIBezierPath bezierPathWithRoundedRect:self.rightBgView.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
    self.rightBgLayer.path = rightPath.CGPath;
}

@end


#pragma mark - QNPKView

/**
 PK视图
 
 height：22
 */
@interface QNPKView()

//倒计时
@property (nonatomic, strong) QNPKCountDownView *countDownView;
//分数视图
@property (nonatomic, strong) QNPKScoreView *scoreView;

//PK打榜倒计时
@property (nonatomic, strong) QNCountDownTimer *pkTimer;
//PK惩罚倒计时
@property (nonatomic, strong) QNCountDownTimer *penaltyTimer;

@property (nonatomic, copy) dispatch_block_t onFinishBlock;

@end

@implementation QNPKView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addChilden];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Public Methods

/**
 开始PK倒计时
 
 (内部有2个倒计时：PK打榜倒计时、PK惩罚倒计时）
 duration: （倒计时）剩余总时间
 penaltyDuration：惩罚持续时间
 */
- (void)startPKCountDown:(double)duration penaltyDuration:(double)penaltyDuration onFinish:(dispatch_block_t)onFinishBlock {
    
    self.onFinishBlock = onFinishBlock;
    
    /**
     逻辑：
     如果 剩余总时间 <= 惩罚持续时间，则：直接启动惩罚倒计时
     如果 剩余总时间 > 惩罚持续时间，则：先启动打榜倒计时，结束后，再启动惩罚倒计时
     */
    if (duration <= penaltyDuration) { //直接启动惩罚倒计时
        //剩余惩罚时间
        double remainder = penaltyDuration - duration;
        [self startPenaltyTimer:remainder];
    } else { //先启动打榜倒计时，结束后，再启动惩罚倒计时
        //PK打榜剩余时间
        double remainder = duration - penaltyDuration;
        [self startPKTimer:remainder penaltyDuration:penaltyDuration];
    }
}

/**
 停止PK倒计时
 */
- (void)stopPKCountDown {
    [self stopPKTimer];
    [self stopPenaltyTimer];
}

//更新分数
- (void)updateViewWithMyScore:(NSString *)myScore otherScore:(NSString *)otherScore {
    [self.scoreView updateViewWithMyScore:myScore otherScore:otherScore];
}

#pragma mark - Private Methods

- (void)addChilden {
    [self addSubview:self.countDownView];
    [self addSubview:self.scoreView];
}

- (void)setupConstraints {
    
    [self.countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kPKCountDownViewWidth);
        make.height.mas_equalTo(kPKCountDownViewHeight);
        make.bottom.equalTo(self.mas_top);
        make.centerX.equalTo(self);
    }];
    
    [self.scoreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(4);
        make.left.equalTo(self).offset(8);
        make.right.equalTo(self).offset(-8);
        make.height.mas_equalTo(18);
    }];
}

- (QNPKCountDownView *)countDownView {
    if (!_countDownView) {
        _countDownView = [[QNPKCountDownView alloc] initWithFrame:CGRectZero];
    }
    return _countDownView;
}

- (QNPKScoreView *)scoreView {
    if (!_scoreView) {
        _scoreView = [[QNPKScoreView alloc] initWithFrame:CGRectZero];
    }
    return _scoreView;
}

#pragma mark - Timer Methods

/**
 开始PK打榜计时器
 */
- (void)startPKTimer:(double)duration penaltyDuration:(double)penaltyDuration {
    if (duration < 1) { //兜底保护
        //直接 启动PK惩罚倒计时
        [self startPenaltyTimer:penaltyDuration];
        return;
    }
    
    if(!self.pkTimer) { //正常流程
        __weak typeof(self) weakSelf = self;
        //启动PK倒计时
        self.pkTimer = [QNCountDownTimer startTimer:duration interval:1.f onTime:^(double remainTime) {
            //刷新（PK打榜）倒计时视图
            [weakSelf.countDownView updateViewWithTime:remainTime countDownType:QNPKCountDownTypePK];
        } onFinish:^{
            //启动PK惩罚倒计时
            [weakSelf startPenaltyTimer:penaltyDuration];
        }];
    }
}

/**
 停止PK打榜计时器
 */
- (void)stopPKTimer {
    if (self.pkTimer) {
        [self.pkTimer cancel];
        self.pkTimer = nil;
    }
}

/**
 开始PK惩罚计时器
 */
- (void)startPenaltyTimer:(double)penaltyDuration {
    if (penaltyDuration < 1) { //兜底保护
        //直接 结束回调
        if (self.onFinishBlock) {
            self.onFinishBlock();
            self.onFinishBlock = nil;
        }
        return;
    }
    
    if(!self.penaltyTimer) {
        __weak typeof(self) weakSelf = self;
        //启动倒计时
        self.penaltyTimer = [QNCountDownTimer startTimer:penaltyDuration interval:1.f onTime:^(double remainTime) {
            //刷新（惩罚）倒计时视图
            [weakSelf.countDownView updateViewWithTime:remainTime countDownType:QNPKCountDownTypePenalty];
        } onFinish:^{
            //最终的倒计时，结束回调
            if (weakSelf.onFinishBlock) {
                weakSelf.onFinishBlock();
                weakSelf.onFinishBlock = nil;
            }
        }];
    }
}

/**
 停止PK惩罚计时器
 */
- (void)stopPenaltyTimer {
    if (self.penaltyTimer) {
        [self.penaltyTimer cancel];
        self.penaltyTimer = nil;
    }
}


@end

