//
//  ExplainingGoodView.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/14.
//

#import "ExplainingGoodView.h"
#import "GoodsModel.h"

@interface ExplainingGoodView ()
//商品图
@property (nonatomic,strong)UIImageView *iconImageView;
//商品序号
@property (nonatomic,strong)UILabel *orderLabel;
//商品名称
@property (nonatomic,strong)UILabel *titleLabel;
//现价
@property (nonatomic,strong)UILabel *currentPriceLabel;
//购买按钮
@property (nonatomic,strong)UIButton *buyButton;

@property (nonatomic,strong)GoodsModel *itemModel;
@end

@implementation ExplainingGoodView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10;
        self.clipsToBounds = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buy:)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tap];
        
        [self iconImageView];
        [self orderLabel];
        [self titleLabel];
        [self currentPriceLabel];
        [self buyButton];
    }
    
    return self;
    
}


- (void)updateWithModel:(GoodsModel *)itemModel {
    self.itemModel = itemModel;
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:itemModel.thumbnail]];
    self.orderLabel.text = itemModel.order;
    self.titleLabel.text = itemModel.title;
    self.currentPriceLabel.text = itemModel.current_price;
}

- (void)buy:(UIButton *)button {

    if (self.buyClickedBlock) {
        self.buyClickedBlock(self.itemModel);
    }
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]init];
        _iconImageView.clipsToBounds = YES;
        _iconImageView.layer.cornerRadius = 10;
        [self addSubview:_iconImageView];
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-5);
            make.top.left.equalTo(self).offset(5);
            make.height.mas_equalTo(self.frame.size.width - 10);
        }];
    }
    return _iconImageView;
}

- (UILabel *)orderLabel {
    if (!_orderLabel) {
        _orderLabel = [[UILabel alloc]init];
        _orderLabel.backgroundColor = [[UIColor colorWithHexString:@"000000"] colorWithAlphaComponent:0.6];
        _orderLabel.textColor = [UIColor whiteColor];
        _orderLabel.text = @"0";
        _orderLabel.textAlignment = NSTextAlignmentCenter;
        _orderLabel.clipsToBounds = YES;
        _orderLabel.font = [UIFont systemFontOfSize:8];
        [self.iconImageView addSubview:_orderLabel];
        [_orderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.iconImageView);
            make.height.mas_equalTo(20);
            make.width.mas_equalTo(25);
        }];
    }
    return _orderLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.text = @"手机";
        _titleLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.iconImageView);
            make.top.equalTo(self.iconImageView.mas_bottom).offset(5);
            make.height.mas_equalTo(20);
        }];
    }
    return _titleLabel;
}

- (UILabel *)currentPriceLabel {
    if (!_currentPriceLabel) {
        _currentPriceLabel = [[UILabel alloc]init];
        _currentPriceLabel.backgroundColor = [[UIColor colorWithHexString:@"E34D59"] colorWithAlphaComponent:0.6];
        _currentPriceLabel.textColor = [UIColor whiteColor];
        _currentPriceLabel.text = @"¥399";
        _currentPriceLabel.clipsToBounds = YES;
        _currentPriceLabel.layer.cornerRadius = 5;
        _currentPriceLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_currentPriceLabel];
        [_currentPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.titleLabel);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
            make.bottom.equalTo(self.mas_bottom).offset(-5);
        }];
    }
    return _currentPriceLabel;
}


- (UIButton *)buyButton {
    if (!_buyButton) {
        _buyButton = [[UIButton alloc]init];
        [_buyButton setBackgroundImage:[UIImage imageNamed:@"rob"] forState:UIControlStateNormal];;
        _buyButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_buyButton setTitle:@"抢" forState:UIControlStateNormal];
        _buyButton.clipsToBounds = YES;
        [_buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_buyButton addTarget:self action:@selector(buy:) forControlEvents:UIControlEventTouchUpInside];
        [self.currentPriceLabel addSubview:_buyButton];
        [_buyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(self.currentPriceLabel);
        }];
    }
    return _buyButton;
}

@end
