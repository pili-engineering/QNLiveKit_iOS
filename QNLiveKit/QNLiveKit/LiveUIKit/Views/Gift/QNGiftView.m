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
        self.backgroundColor = [UIColor colorWithHexString:@"#0B1C29"];
        self.frame = CGRectMake(0, SCREEN_H, SCREEN_W, 315);
        
        [self setUI];
        [self setData];
    }
    return self;
}

- (void)layoutSubviews {
    [self makeupConstraints];
}

- (void)makeupConstraints {
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(48);
        make.left.right.top.equalTo(self);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(200);
        make.left.right.equalTo(self);
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
   
//    NSMutableArray *dataArr = [NSMutableArray array];
//
//    SendGiftModel *model = [SendGiftModel new];
//    model.gift_id = @"0";
//    model.img = @"gift_cake";
//    model.name = @"蛋糕";
//    model.amount = @"20";
//    model.animation_img = @"cat";
//    [dataArr addObject:model];
//
//    self.dataArray = [dataArr copy];
}

#pragma mark -设置UI
- (void)setUI {
    [self addSubview:self.topView];
    [self addSubview:self.collectionView];
    
    
//    UIButton *sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bottomView.frame.size.width-80, 0, 80, 44)];
//    [sendBtn setBackgroundColor:[UIColor orangeColor]];
//    [sendBtn setTitle:@"赠送" forState:UIControlStateNormal];
//    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [sendBtn addTarget:self action:@selector(p_ClickSendBtn) forControlEvents:UIControlEventTouchUpInside];
//    [bottomView addSubview:sendBtn];
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
- (void)p_ClickSendBtn {
    
    //找到已选中的礼物
    BOOL isBack = NO;
    for (QNSendGiftModel *model in self.dataArray) {
        if (model.isSelected) {
            isBack = YES;
            if ([self.delegate respondsToSelector:@selector(giftViewSendGiftInView:data:)]) {
                [self.delegate giftViewSendGiftInView:self data:model];
            }
        }
    }
    if (!isBack) {
        //提示选择礼物
        NSLog(@"没有选择礼物");
    }
}

- (void)showGiftView {
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, SCREEN_H - 315, SCREEN_W, 315);
    }];
}

- (void)hiddenGiftView {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, SCREEN_H, SCREEN_W, 315);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self hiddenGiftView];
}

@end
