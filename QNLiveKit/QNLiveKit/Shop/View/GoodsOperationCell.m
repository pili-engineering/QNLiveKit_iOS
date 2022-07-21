//
//  GoodsOperationCell.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/14.
//

#import "GoodsOperationCell.h"
#import "GoodsModel.h"

@interface GoodsOperationCell ()
//选中按钮
@property (nonatomic,strong)UIButton *selectButton;
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
//排序按钮
@property (nonatomic,strong)UIButton *sortButton;

@property (nonatomic,strong)GoodsModel *itemModel;
@end

@implementation GoodsOperationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self selectButton];
        [self iconImageView];
        [self orderLabel];
        [self titleLabel];
        [self tagLabel];
        [self currentPriceLabel];
//        [self sortButton];
        
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
    self.selectButton.selected = itemModel.isSelected;
}

- (void)selectButtonClicked:(UIButton *)button {
    button.selected = !button.selected;
    self.itemModel.isSelected = button.selected;
    if (self.selectButtonClickedBlock) {
        self.selectButtonClickedBlock(self.itemModel);
    }
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [[UIButton alloc]init];
        [_selectButton setImage:[UIImage imageNamed:@"good_no_select"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"good_select"] forState:UIControlStateSelected];
        _selectButton.selected = NO;
        [_selectButton addTarget:self action:@selector(selectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_selectButton];
        [_selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.centerY.equalTo(self.contentView);
            make.width.height.mas_equalTo(30);
        }];
    }
    return _selectButton;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]init];
        _iconImageView.clipsToBounds = YES;
        _iconImageView.layer.cornerRadius = 10;
        [self.contentView addSubview:_iconImageView];
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.selectButton.mas_right).offset(20);
            make.centerY.equalTo(self.contentView);
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


- (UIButton *)sortButton {
    if (!_sortButton) {
        _sortButton = [[UIButton alloc]init];
        [_sortButton setImage:[UIImage imageNamed:@"sort"] forState:UIControlStateNormal];
//        [_buyButton addTarget:self action:@selector(buy:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_sortButton];
        [_sortButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.iconImageView.mas_bottom);
            make.right.equalTo(self.contentView.mas_right).offset(-15);
        }];
    }
    return _sortButton;
}


@end
