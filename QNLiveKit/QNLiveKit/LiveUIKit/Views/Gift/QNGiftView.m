//
//  GiftView.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/5.
//

#import "QNGiftView.h"
#import "QNGiftCollectionViewCell.h"
#import "QNSendGiftModel.h"
#import "QNHorizontalLayout.h"
#import "QLiveNetworkUtil.h"
#import <Masonry/Masonry.h>

static NSString *cellID = @"GiftCollectionViewCell";

@interface QNGiftView()<UICollectionViewDelegate,UICollectionViewDataSource>

// 覆盖区域，用于处理点击事件，隐藏自己
@property (nonatomic, strong) UIView *coverView;


@property (nonatomic, strong) UIView *pannelView;
/** 顶部标题栏 */
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *topTitleLabel;
@property (nonatomic, strong) UIButton *topCloseButton;

/** 礼物显示 */
@property(nonatomic,strong) UICollectionView *collectionView;

/** 上一次点击的model */
@property(nonatomic,strong) QNSendGiftModel *preModel;

@end

@implementation QNGiftView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.frame = CGRectMake(0, SCREEN_H, SCREEN_W, SCREEN_H);
        
        [self setUI];
        [self setData];
    }
    return self;
}

- (void)layoutSubviews {
    [self makeupConstraints];
}

- (void)makeupConstraints {
    [self.pannelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(315);
        make.left.right.bottom.equalTo(self);
    }];
    
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.bottom.equalTo(self.pannelView.mas_top);
    }];
    
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(48);
        make.left.right.top.equalTo(self.pannelView);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(200);
        make.left.right.equalTo(self.pannelView);
        make.top.equalTo(self.topView.mas_bottom).offset(12);
    }];
    
    [self makeupTopConstraints];
}

- (void)makeupTopConstraints {
    [self.topTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(24);
        make.center.equalTo(self.topView);
    }];
    
    [self.topCloseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.centerY.equalTo(self.topView);
        make.right.equalTo(self.topView).offset(-16);
    }];
}

- (void)setData {
    NSString *action = [NSString stringWithFormat:@"client/gift/config/%@",@"1"];
    [QLiveNetworkUtil getRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        
        NSArray <QNSendGiftModel *> *list = [QNSendGiftModel mj_objectArrayWithKeyValuesArray:responseData];
        self.dataArray = list;
        
        } failure:^(NSError * _Nonnull error) {
            (nil);
        }];
}

#pragma mark -设置UI
- (void)setUI {
    [self addSubview:self.coverView];
    [self addSubview:self.pannelView];
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:CGRectZero];
        _coverView.backgroundColor = [UIColor clearColor];
        
        _coverView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
        [tapGesture setNumberOfTapsRequired:1];

        [_coverView addGestureRecognizer:tapGesture];
    }
    return _coverView;
}

- (UIView *)pannelView {
    if (!_pannelView) {
        _pannelView = [[UIView alloc] initWithFrame:CGRectZero];
        _pannelView.backgroundColor = [UIColor colorWithHexString:@"#0B1C29"];
        
        [_pannelView addSubview:self.topView];
        [_pannelView addSubview:self.collectionView];
    }
    return _pannelView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
        _topView.backgroundColor = [UIColor colorWithHexString:@"#0B1C29"];
        
        [_topView addSubview:self.topTitleLabel];
        [_topView addSubview:self.topCloseButton];
    }
    return _topView;
}

- (UILabel *)topTitleLabel {
    if (!_topTitleLabel) {
        _topTitleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _topTitleLabel.text = @"礼物打赏";
        _topTitleLabel.textAlignment = NSTextAlignmentCenter;
        _topTitleLabel.textColor = [UIColor whiteColor];
        _topTitleLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    return _topTitleLabel;
}

- (UIButton *)topCloseButton {
    if (!_topCloseButton) {
        _topCloseButton = [[UIButton alloc]initWithFrame:CGRectZero];
        [_topCloseButton setImage:[UIImage imageNamed:@"white_close"] forState:UIControlStateNormal];
        [_topCloseButton addTarget:self action:@selector(hiddenGiftView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _topCloseButton;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        QNHorizontalLayout *layout = [[QNHorizontalLayout alloc] init];
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor colorWithHexString:@"#0B1C29"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.bounces = NO;
        [_collectionView registerClass:[QNGiftCollectionViewCell class] forCellWithReuseIdentifier:cellID];
    }
    return _collectionView;
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QNGiftCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    if (indexPath.item < self.dataArray.count) {
        QNSendGiftModel *model = self.dataArray[indexPath.item];
        cell.model = model;
    }
    
    __weak typeof(self) weakSelf = self;
    cell.payGiftBlock = ^(QNSendGiftModel *giftModel) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf payGift:giftModel];
    };
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item < self.dataArray.count) {
        QNSendGiftModel *model = self.dataArray[indexPath.item];
        model.isSelected = !model.isSelected;
        if ([self.preModel isEqual:model]) {
            [collectionView reloadData];
        }else {
            self.preModel.isSelected = NO;
            [UIView performWithoutAnimation:^{
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            }];

        }
        self.preModel = model;
    }

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

#pragma mark -发送
- (void)payGift:(QNSendGiftModel *)model {

    if ([self.delegate respondsToSelector:@selector(giftViewSendGiftInView:data:)]) {
        [self.delegate giftViewSendGiftInView:self data:model];
    }
}

- (void)showGiftView {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
    }];
}

- (void)hiddenGiftView {
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, SCREEN_H, SCREEN_W, SCREEN_H);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)tapEvent:(UITapGestureRecognizer *)gesture {
    [self hiddenGiftView];
}

@end
