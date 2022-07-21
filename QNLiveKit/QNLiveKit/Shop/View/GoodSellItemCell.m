//
//  GoodSellItemCell.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/13.
//

#import "GoodSellItemCell.h"
#import "GoodsModel.h"
#import "QAlertView.h"

@interface GoodSellItemCell ()
//商品图
@property (nonatomic,strong)UIImageView *iconImageView;
//下架覆盖层
@property (nonatomic,strong) UIButton *downView;
//商品序号
@property (nonatomic,strong)UILabel *orderLabel;
//商品名称
@property (nonatomic,strong)UILabel *titleLabel;
//标签
@property (nonatomic,strong)UILabel *tagLabel;
//现价
@property (nonatomic,strong)UILabel *currentPriceLabel;
//原价
@property (nonatomic,strong)UILabel *originPriceLabel;
//下架按钮
@property (nonatomic,strong)UIButton *takeDownButton;
//录制按钮
@property (nonatomic,strong)UIButton *recordButton;
//讲解按钮
@property (nonatomic,strong)UIButton *explainButton;

@property (nonatomic,strong)GoodsModel *itemModel;

@end

@implementation GoodSellItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click)];
        [self.contentView addGestureRecognizer:tap];
        self.contentView.userInteractionEnabled = YES;
        [self iconImageView];
        [self downView];
        [self orderLabel];
        [self titleLabel];
        [self tagLabel];
        [self currentPriceLabel];
        [self takeDownButton];
        [self explainButton];
//        [self recordButton];
        
    }
    return self;
}

- (void)click {
    if(self.goodClickedBlock) {
        self.goodClickedBlock(self.itemModel);
    }
}

- (void)updateWithModel:(GoodsModel *)itemModel {
    self.itemModel = itemModel;
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:itemModel.thumbnail]];
    self.titleLabel.text = itemModel.title;
    self.orderLabel.text = itemModel.order;
    self.tagLabel.text = [itemModel.tags componentsSeparatedByString:@","].firstObject;
    self.currentPriceLabel.text = itemModel.current_price;
    if (itemModel.status == QLiveGoodsStatusTakeOn) {
        self.downView.hidden = YES;
        [self.takeDownButton setTitle:@"下架商品" forState:UIControlStateNormal];
    } else {
        self.downView.hidden = NO;
        [self.takeDownButton setTitle:@"上架商品" forState:UIControlStateNormal];
    }
    
    UIColor *explainButtonTitleColor;
    NSString *explainButtonTitle;
    
    if (itemModel.isExplaining) {
        
        explainButtonTitle = @"结束讲解";
        self.explainButton.backgroundColor = [UIColor colorWithHexString:@"F5F5F5"];
        explainButtonTitleColor = [UIColor colorWithHexString:@"E34D59"];
        self.explainButton.userInteractionEnabled = YES;
        
    } else {
        
        if (itemModel.status == QLiveGoodsStatusTakeOn) {
            self.explainButton.backgroundColor = [UIColor colorWithHexString:@"E34D59"];
            self.explainButton.userInteractionEnabled = YES;
        } else {
            self.explainButton.backgroundColor = [[UIColor colorWithHexString:@"E34D59"] colorWithAlphaComponent:0.4];
            self.explainButton.userInteractionEnabled = NO;
        }
        explainButtonTitle = @"讲解";
        explainButtonTitleColor = [UIColor whiteColor];
    }
        
    [self.explainButton setTitle:explainButtonTitle forState:UIControlStateNormal];
    [self.explainButton setTitleColor:explainButtonTitleColor forState:UIControlStateNormal];
}

- (void)takeDown:(UIButton *)button {
    
    NSString *title = self.itemModel.status == QLiveGoodsStatusTakeOn ? @"确定下架该商品吗？" : @"确定上架该商品吗？";
    
    [QAlertView showBaseAlertWithTitle:title content:@"" handler:^(UIAlertAction * _Nonnull action) {
        if (self.takeDownClickedBlock) {
            self.takeDownClickedBlock(self.itemModel);
        }
    }];
    
}

- (void)explain:(UIButton *)button {
    self.itemModel.isExplaining = !self.itemModel.isExplaining;
    if (self.explainClickedBlock) {
        self.explainClickedBlock(self.itemModel);
    }
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]init];
        _iconImageView.clipsToBounds = YES;
        _iconImageView.layer.cornerRadius = 10;
        _iconImageView.backgroundColor = [UIColor colorWithHexString:@"E34D59"];
        [self.contentView addSubview:_iconImageView];
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.top.equalTo(self.contentView).offset(5);
            make.width.height.mas_equalTo(80);
        }];
    }
    return _iconImageView;
}

- (UIButton *)downView {
    if (!_downView) {
        _downView = [[UIButton alloc]init];
        _downView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
        [_downView setTitle:@"下架已隐藏" forState:UIControlStateNormal];
        _downView.clipsToBounds = YES;
        _downView.layer.cornerRadius = 10;
        [_downView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _downView.titleLabel.font = [UIFont systemFontOfSize:12];
        _downView.hidden = YES;
        [self.contentView addSubview:_downView];
        
        [_downView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.equalTo(self.iconImageView);
        }];
    }
    return _downView;
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
            make.width.mas_equalTo(25);
            make.height.mas_equalTo(20);
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
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(15);
            make.right.equalTo(self.contentView.mas_right).offset(-15);
            make.top.equalTo(self.iconImageView);
        }];
    }
    return _titleLabel;
}

- (UILabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [[UILabel alloc]init];
        _tagLabel.backgroundColor = [UIColor orangeColor];
        _tagLabel.textColor = [UIColor whiteColor];
        _tagLabel.text = @"大减价";
        _tagLabel.font = [UIFont systemFontOfSize:10];
        [self.contentView addSubview:_tagLabel];
        [_tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(15);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(8);
        }];
    }
    return _tagLabel;
}

- (UILabel *)currentPriceLabel {
    if (!_currentPriceLabel) {
        _currentPriceLabel = [[UILabel alloc]init];
        _currentPriceLabel.textColor = [UIColor colorWithHexString:@"E34D59"];
        _currentPriceLabel.text = @"¥399";
        _currentPriceLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_currentPriceLabel];
        [_currentPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.tagLabel);
            make.bottom.equalTo(self.iconImageView.mas_bottom);
        }];
    }
    return _currentPriceLabel;
}

- (UIButton *)takeDownButton {
    if (!_takeDownButton) {
        _takeDownButton = [[UIButton alloc]init];
        _takeDownButton.backgroundColor = [UIColor colorWithHexString:@"F5F5F5"];
        _takeDownButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_takeDownButton setTitle:@"下架商品" forState:UIControlStateNormal];
        [_takeDownButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_takeDownButton addTarget:self action:@selector(takeDown:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_takeDownButton];
        [_takeDownButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.iconImageView);
            make.top.equalTo(self.iconImageView.mas_bottom).offset(10);
            make.width.mas_equalTo(70);
            make.height.mas_equalTo(25);
        }];
    }
    return _takeDownButton;
}

- (UIButton *)explainButton {
    if (!_explainButton) {
        _explainButton = [[UIButton alloc]init];
        _explainButton.backgroundColor = [UIColor colorWithHexString:@"E34D59"];
        _explainButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_explainButton setTitle:@"讲解" forState:UIControlStateNormal];
        [_explainButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_explainButton addTarget:self action:@selector(explain:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_explainButton];
        [_explainButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.takeDownButton);
            make.right.equalTo(self.contentView.mas_right).offset(-15);
            make.width.mas_equalTo(75);
            make.height.mas_equalTo(25);
        }];
    }
    return _explainButton;
}

- (UIButton *)recordButton {
    if (!_recordButton) {
        _recordButton = [[UIButton alloc]init];
        _recordButton.backgroundColor = [UIColor colorWithHexString:@"F5F5F5"];
        [_recordButton setTitle:@"录制" forState:UIControlStateNormal];
        _recordButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.contentView addSubview:_recordButton];
        [_recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.takeDownButton);
            make.right.equalTo(self.explainButton.mas_left).offset(-10);
            make.width.mas_equalTo(75);
            make.height.mas_equalTo(25);
        }];
    }
    return _recordButton;
}

@end
