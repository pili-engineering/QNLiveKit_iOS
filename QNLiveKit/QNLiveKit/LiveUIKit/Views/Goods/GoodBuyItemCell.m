//
//  GoodBuyItemCell.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/14.
//

#import "GoodBuyItemCell.h"
#import "GoodsModel.h"

@interface GoodBuyItemCell()
//商品图
@property (nonatomic,strong)UIImageView *iconImageView;
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
//购买按钮
@property (nonatomic,strong)UIButton *buyButton;
//讲解中View
@property (nonatomic,strong)UIView *explainView;

@property (nonatomic,strong)GoodsModel *itemModel;


@end

@implementation GoodBuyItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        [self iconImageView];
        [self orderLabel];
        [self titleLabel];
        [self tagLabel];
        [self currentPriceLabel];
        [self buyButton];
        [self explainView];
        
    }
    return self;
}

- (void)updateWithModel:(GoodsModel *)itemModel {
    self.itemModel = itemModel;
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:itemModel.thumbnail]];
    self.orderLabel.text = itemModel.order;
    self.titleLabel.text = itemModel.title;
    self.tagLabel.text = [itemModel.tags componentsSeparatedByString:@","].firstObject;
    self.currentPriceLabel.text = itemModel.current_price;
    self.explainView.hidden = !itemModel.isExplaining;
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
        [self.contentView addSubview:_iconImageView];
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.top.equalTo(self.contentView).offset(5);
            make.width.height.mas_equalTo(80);
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
            make.left.equalTo(self.tagLabel).offset(15);
            make.bottom.equalTo(self.iconImageView.mas_bottom);
        }];
    }
    return _currentPriceLabel;
}


- (UIButton *)buyButton {
    if (!_buyButton) {
        _buyButton = [[UIButton alloc]init];
        _buyButton.backgroundColor = [UIColor colorWithHexString:@"E34D59"];
        _buyButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_buyButton setTitle:@"去购买" forState:UIControlStateNormal];
        [_buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_buyButton addTarget:self action:@selector(buy:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_buyButton];
        [_buyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.iconImageView.mas_bottom);
            make.right.equalTo(self.contentView.mas_right).offset(-15);
            make.width.mas_equalTo(75);
            make.height.mas_equalTo(25);
        }];
    }
    return _buyButton;
}

- (UIView *)explainView {
    if (!_explainView) {
        _explainView = [[UIView alloc]init];
        _explainView.backgroundColor = [[UIColor colorWithHexString:@"EF4149"] colorWithAlphaComponent:0.75];
        _explainView.layer.cornerRadius = 10;
        _explainView.clipsToBounds = YES;
        [self.iconImageView addSubview:_explainView];
        [_explainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.iconImageView);
            make.height.mas_equalTo(25);
        }];
        
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"explaining"]];
        [_explainView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.explainView.mas_centerY);
            make.left.equalTo(self.explainView).offset(15);
        }];
        
        UILabel *explainLabel = [[UILabel alloc]init];
        explainLabel.text = @"讲解中";
        explainLabel.textColor = [UIColor whiteColor];
        explainLabel.font = [UIFont systemFontOfSize:12];
        [_explainView addSubview:explainLabel];
        [explainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.explainView.mas_centerY);
            make.left.equalTo(imageView.mas_right).offset(3);
        }];
        _explainView.hidden = YES;
    }
    return _explainView;
}

@end
