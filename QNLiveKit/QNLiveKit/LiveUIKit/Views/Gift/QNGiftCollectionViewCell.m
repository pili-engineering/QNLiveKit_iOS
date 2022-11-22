//
//  GiftCollectionViewCell.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/5.
//

#import "QNGiftCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "QNSendGiftModel.h"

@interface QNGiftCollectionViewCell()

@property(nonatomic,strong) UIView *bgView;

@property(nonatomic,strong) UIImageView *iconImageView;

@property(nonatomic,strong) UILabel *nameLabel;

@property(nonatomic,strong) UILabel *amountLabel;

@property (nonatomic, strong) UIButton *payButton;
@end

@implementation QNGiftCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.layer.cornerRadius = 4.0;
        self.contentView.layer.masksToBounds = YES;
        
        [self p_SetUI];
    }
    return self;
}

#pragma mark -设置UI
- (void)p_SetUI {
    [self.contentView addSubview:self.bgView];
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.amountLabel];
    [self.contentView addSubview:self.payButton];
}

- (void)layoutSubviews {
    if (self.model.isSelected) {
        [self makeupSelectedContraints];
    } else {
        [self makeupNormalConstraints];
    }
}

- (void)makeupNormalConstraints {
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.contentView);
    }];
    
    [self.iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(42, 42));
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(14);
    }];
    
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(16);
        make.left.width.equalTo(self.contentView);
        make.top.equalTo(self.iconImageView.mas_bottom).offset(14);
    }];
    
    [self.amountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(14);
        make.left.width.equalTo(self.contentView);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(-2);
    }];
}


- (void)makeupSelectedContraints {
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.contentView);
    }];
    
    [self.iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(42, 42));
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(8);
    }];
    
    
    [self.amountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(16);
        make.left.width.equalTo(self.contentView);
        make.top.equalTo(self.iconImageView.mas_bottom).offset(8);
    }];
    
    [self.payButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(24);
        make.left.right.bottom.equalTo(self.contentView);
    }];
}


- (void)setModel:(QNSendGiftModel *)model {
    _model = model;
    
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.img] placeholderImage:[UIImage imageNamed:@""]];
    self.nameLabel.text = model.name;
    self.amountLabel.text = model.amount;
    
    if (model.isSelected) {
        [self.bgView setHidden:NO];
        
        self.amountLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
        self.amountLabel.font = [UIFont systemFontOfSize:10];
        
        [self.nameLabel setHidden:YES];
        [self.payButton setHidden:NO];
    } else {
        [self.bgView setHidden:YES];
        
        self.amountLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        self.amountLabel.font = [UIFont systemFontOfSize:9];
        
        [self.nameLabel setHidden:NO];
        [self.payButton setHidden:YES];
    }
    [self layoutIfNeeded];
}


#pragma mark - SubViews
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 100)];
        UIColor *color1 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.15];
        UIColor *color2 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.05];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.bounds = _bgView.bounds;
        gradientLayer.frame = _bgView.bounds;
        gradientLayer.colors = [NSArray arrayWithObjects:(id)[color1 CGColor],(id)[color2 CGColor],nil];
        gradientLayer.startPoint = CGPointMake(0.5, 0);
        gradientLayer.endPoint = CGPointMake(0.5, 1);
        [_bgView.layer addSublayer:gradientLayer];
        
        gradientLayer.borderWidth = 0;
    }
    return _bgView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _iconImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.font = [UIFont systemFontOfSize:10];
        _nameLabel.text = @"礼物名";
    }
    return _nameLabel;
}

- (UILabel *)amountLabel {
    if (!_amountLabel) {
        _amountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _amountLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        _amountLabel.font = [UIFont systemFontOfSize:9];
        _amountLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _amountLabel;
}

- (UIButton *)payButton {
    if (!_payButton) {
        _payButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _payButton.backgroundColor = [UIColor colorWithHexString:@"#EF4149"];
        
        [_payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _payButton.titleLabel.font = [UIFont systemFontOfSize:10];
        [_payButton setTitle:@"支付" forState:UIControlStateNormal];
        
        [_payButton addTarget:self action:@selector(payGift) forControlEvents:UIControlEventTouchUpInside];
    }
    return _payButton;
}

- (void)payGift {
    if (self.payGiftBlock) {
        self.payGiftBlock(self.model);
    }
}


@end
