//
//  QMessageBaseCell.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/10.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "QMessageBaseCell.h"

@implementation QMessageBaseCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.bgView];
    }
    return self;
}

- (void)layoutSubviews {
    [self makeConstraints];
}

- (void)makeConstraints {
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.left.top.equalTo(self);
    }];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarImageView.mas_right).offset(4);
        make.top.bottom.right.equalTo(self);
    }];
}

- (void)setDataModel:(QNIMMessageObject *)model {
    self.model = model;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.layer.cornerRadius = 12;
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _avatarImageView;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc]initWithFrame:CGRectZero];
        
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha = 0.25;
        _bgView.layer.cornerRadius = 6;
    }
    return _bgView;
}
@end
