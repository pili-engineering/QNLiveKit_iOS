//
//  GoodStatusView.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/15.
//

#import "GoodStatusView.h"

@interface GoodStatusView ()

@property (nonatomic,strong)UIButton *allButton;

@property (nonatomic,strong)UIButton *takeOnButton;

@property (nonatomic,strong)UIButton *takeDownButton;

@end
@implementation GoodStatusView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        [self allButton];
        [self takeOnButton];
        [self takeDownButton];
        
    }
    return self;
}

- (void)updateWithModel:(NSArray <GoodsModel *> *)itemModels {
    [self.allButton setTitle:[NSString stringWithFormat:@"全部%ld",itemModels.count] forState:UIControlStateNormal];
    NSMutableArray *onArr = [NSMutableArray array];
    NSMutableArray *downArr = [NSMutableArray array];
    for (GoodsModel *good in itemModels) {
        if (good.status == QLiveGoodsStatusTakeOn) {
            [onArr addObject:good];
        } else if (good.status == QLiveGoodsStatusTakeDown) {
            [downArr addObject:good];
        }
    }
    [self.takeOnButton setTitle:[NSString stringWithFormat:@"上架中%ld",onArr.count] forState:UIControlStateNormal];
    [self.takeDownButton setTitle:[NSString stringWithFormat:@"已下架%ld",downArr.count] forState:UIControlStateNormal];
}

- (void)takeOnClick:(UIButton *)button {
    self.allButton.selected = NO;
    self.takeOnButton.selected = YES;
    self.takeDownButton.selected=NO;
    if (self.typeClickedBlock) {
        self.typeClickedBlock(QLiveGoodsStatusTakeOn);
    }
}

- (void)takeDownClick:(UIButton *)button {
    self.allButton.selected = NO;
    self.takeOnButton.selected = NO;
    self.takeDownButton.selected=YES;
    if (self.typeClickedBlock) {
        self.typeClickedBlock(QLiveGoodsStatusTakeDown);
    }
}

- (void)allClick:(UIButton *)button {
    self.allButton.selected = YES;
    self.takeOnButton.selected = NO;
    self.takeDownButton.selected=NO;
    if (self.typeClickedBlock) {
        self.typeClickedBlock(QLiveGoodsStatusTakeAll);
    }
}

- (UIButton *)allButton {
    if (!_allButton) {
        _allButton = [[UIButton alloc]init];
        _allButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_allButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _allButton.selected=YES;
        [_allButton setTitleColor:[UIColor colorWithHexString:@"EF4149"] forState:UIControlStateSelected];
        [_allButton addTarget:self action:@selector(allClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_allButton];
        [_allButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self);
            make.width.mas_equalTo(SCREEN_W/3);
            make.height.mas_equalTo(self.frame.size.height);
        }];
    }
    return _allButton;
}

- (UIButton *)takeOnButton {
    if (!_takeOnButton) {
        _takeOnButton = [[UIButton alloc]init];
        _takeOnButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _takeOnButton.selected = NO;
        [_takeOnButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_takeOnButton setTitleColor:[UIColor colorWithHexString:@"EF4149"] forState:UIControlStateSelected];
        [_takeOnButton addTarget:self action:@selector(takeOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_takeOnButton];
        [_takeOnButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self.allButton.mas_right).offset(0);
            make.width.mas_equalTo(SCREEN_W/3);
            make.height.mas_equalTo(self.frame.size.height);
        }];
    }
    return _takeOnButton;
}

- (UIButton *)takeDownButton {
    if (!_takeDownButton) {
        _takeDownButton = [[UIButton alloc]init];
        _takeDownButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _takeDownButton.selected = NO;
        [_takeDownButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_takeDownButton setTitleColor:[UIColor colorWithHexString:@"EF4149"] forState:UIControlStateSelected];
        [_takeDownButton addTarget:self action:@selector(takeDownClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_takeDownButton];
        [_takeDownButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self.takeOnButton.mas_right).offset(0);
            make.width.mas_equalTo(SCREEN_W/3);
            make.height.mas_equalTo(self.frame.size.height);
        }];
    }
    return _takeDownButton;
}



@end
