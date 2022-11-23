//
//  QNGiftMesageView.m
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/23.
//

#import "QNGiftMessageView.h"
#import "QNIMSDK/QNIMSDK.h"

@interface QNGiftMessageView ()

@property (nonatomic, strong) QNIMMessageObject *message;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nickLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIImageView *giftImageView;

@property (nonatomic, assign) NSInteger mode;   //1,2,3

@end

@implementation QNGiftMessageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.contentView];
        [self addSubview:self.avatarImageView];
        [self addSubview:self.nickLabel];
        [self addSubview:self.messageLabel];
        [self addSubview:self.giftImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [self makeupContraints];
}

- (void)makeupContraints {
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(160);
        make.height.mas_equalTo(40);
        make.left.bottom.equalTo(self);
    }];
    
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(36);
        make.height.mas_equalTo(36);
        make.left.equalTo(self.contentView).offset(2);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(68);
        make.height.mas_equalTo(18);
        make.left.equalTo(self.contentView).offset(42);
        make.top.equalTo(self.contentView).offset(4);
    }];
    
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(68);
        make.height.mas_equalTo(12);
        make.left.equalTo(self.contentView).offset(42);
        make.top.equalTo(self.contentView).offset(24);
    }];
    
    if (self.mode == 1) {
        [self.giftImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(32);
            make.left.equalTo(self.contentView).offset(116);
            make.top.equalTo(self.contentView).offset(4);
        }];
    } else {
        [self.giftImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(42);
            make.left.equalTo(self.contentView).offset(118);
            make.top.equalTo(self.contentView).offset(-10);
        }];
    }
}

- (void)showGiftWithMessage:(QNIMMessageObject *)message complete:(void (^)(void))complete {
    [self setupWithMessage:message];
}

- (void)setupWithMessage:(QNIMMessageObject *)message {
    
}

#pragma mark - SubViews
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        [_contentView.layer setCornerRadius:20.0];
        [_contentView.layer setMasksToBounds:YES];
    }
    return _contentView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_avatarImageView.layer setMasksToBounds:YES];
        [_avatarImageView.layer setCornerRadius:18];
    }
    return _avatarImageView;
}

- (UILabel *)nickLabel {
    if (!_nickLabel) {
        _nickLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nickLabel.font = [UIFont systemFontOfSize:12];
        _nickLabel.textColor = [UIColor whiteColor];
    }
    return _nickLabel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.font = [UIFont systemFontOfSize:9];
        _messageLabel.textColor = [UIColor colorWithHexString:@"#E5E5E5"];
    }
    return _messageLabel;
}

- (UIImageView *)giftImageView {
    if (!_giftImageView) {
        _giftImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _giftImageView;
}
@end
