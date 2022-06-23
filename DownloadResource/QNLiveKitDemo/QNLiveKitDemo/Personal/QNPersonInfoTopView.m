//
//  QNPersonInfoTopView.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/12.
//

#import "QNPersonInfoTopView.h"
#import <Masonry/Masonry.h>
#import <YYCategories/YYCategories.h>
#import <SDWebImage/SDWebImage.h>
#import "QNPersonInfoModel.h"

@interface QNPersonInfoTopView ()

@property (nonatomic, strong) UIImageView *titleImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *detailLabel;

@end

@implementation QNPersonInfoTopView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self titleImageView];
        [self titleLabel];
        [self detailLabel];
    }
    return self;
}

- (void)updateWithInfoModel:(QNPersonInfoModel *)infoModel {
    
    NSURL *imageUrl = [NSURL URLWithString:infoModel.avatar];
    [_titleImageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"logo"]];
    
    _titleLabel.text = infoModel.nickname;
}

- (void)changeNickName {
    if (self.changeInfoBlock) {
        self.changeInfoBlock();
    }
}

- (UIImageView *)titleImageView {
    if (!_titleImageView) {
        _titleImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo"]];
        [self addSubview:_titleImageView];
        
        [_titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.mas_equalTo(35);
            make.width.height.mas_equalTo(60);
        }];
    }
    return _titleImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"吴亦凡";
        _titleLabel.textColor = [UIColor whiteColor];
        
        [self addSubview:_titleLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleImageView.mas_right).offset(20);
            make.top.equalTo(self.titleImageView).offset(10);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeNickName)];
        _titleLabel.userInteractionEnabled = YES;
        [_titleLabel addGestureRecognizer:tap];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc]init];
        _detailLabel.text = @"让大家更了解你一下吧";
        _detailLabel.font = [UIFont systemFontOfSize:13];
        _detailLabel.textColor = [UIColor colorWithHexString:@"85C6FF"];
        [self addSubview:_detailLabel];
        
        [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        }];
    }
    return _detailLabel;
}

@end
