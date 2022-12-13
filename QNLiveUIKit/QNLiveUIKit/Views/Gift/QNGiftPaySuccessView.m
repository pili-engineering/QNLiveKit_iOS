//
//  QNGiftPaySuccessView.m
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/24.
//

#import "QNGiftPaySuccessView.h"

@interface QNGiftPaySuccessView ()

@property (nonatomic, strong) UIImageView *successImageView;
@property (nonatomic, strong) UILabel *successLabel;

@end

@implementation QNGiftPaySuccessView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupBackground];
        [self addSubview:self.successImageView];
        [self addSubview:self.successLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [self makeContraints];
}

- (void)makeContraints {
    [self.successImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(42);
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(-17);
    }];
    
    [self.successLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(88);
        make.height.mas_equalTo(22);
        make.centerX.equalTo(self);
        make.top.equalTo(self.successImageView.mas_bottom).offset(15);
    }];
}

#pragma mark - SubViews
- (void)setupBackground {
    self.backgroundColor = [UIColor colorWithHexString:@"#00000040"];
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:8];
}

- (UIImageView *)successImageView {
    if (!_successImageView) {
        _successImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_successImageView setImage:[UIImage imageNamed:@"check_circle"]];
    }
    return _successImageView;
}

- (UILabel *)successLabel {
    if (!_successLabel) {
        _successLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_successLabel setText:@"支付成功"];
        
        [_successLabel setFont:[UIFont systemFontOfSize:14]];
        [_successLabel setTextColor:[UIColor colorWithHexString:@"#4BC310"]];
        [_successLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _successLabel;
}

@end
