//
//  QNGiftMesageView.m
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/23.
//

#import "QNGiftMessageView.h"
#import "QNIMSDK/QNIMSDK.h"
#import "QIMModel.h"
#import "QNGiftMsgModel.h"
#import "QNUserService.h"
#import "QNGiftService.h"

@interface QNGiftMessageView ()

@property (nonatomic, strong) QNIMMessageObject *message;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) CAGradientLayer *contentLayer;

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nickLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIImageView *giftImageView;

@property (nonatomic, assign) NSInteger mode;   //1,2,3
@property (nonatomic, copy) void (^completeBlock)(void) ;
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

- (void)showGiftMessage:(QNIMMessageObject *)message {
    [self setupWithMessage:message];
    
    [self layoutSubviews];
}

- (void)showGiftWithMessage:(QNIMMessageObject *)message complete:(void (^)(void))complete {
    [self setupWithMessage:message];
    [self layoutSubviews];
    
    self.completeBlock = complete;
    
    self.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.frame =CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hiddenGiftShowView) withObject:nil afterDelay:2];
    }];
}

- (void)hiddenGiftShowView {
    [UIView animateWithDuration:0.3 animations:^{
        self.frame =CGRectMake(self.frame.origin.x, self.frame.origin.y-20, self.frame.size.width, self.frame.size.height);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (self.completeBlock) {
            self.completeBlock();
        }
        self.frame =CGRectMake(-self.frame.size.width, self.frame.origin.y+20, self.frame.size.width, self.frame.size.height);
        self.alpha = 1.0;
        self.hidden = YES;
    }];
}

- (void)setupWithMessage:(QNIMMessageObject *)message {
    QIMModel *imModel = [QIMModel mj_objectWithKeyValues:message.content.mj_keyValues];
    QNGiftMsgModel *model = [QNGiftMsgModel mj_objectWithKeyValues:imModel.data];
    if (model.amount < 5000) {
        self.mode = 1;
    } else if (model.amount < 8000) {
        self.mode = 2;
    } else {
        self.mode = 3;
    }
    
    [self updateContentView];
    
    [[QNUserService sharedInstance] getUserByID:model.user_id complete:^(QNLiveUser * _Nonnull user) {
        if (user) {
            [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"titleImage"]];
            self.nickLabel.text = user.nick ? user.nick : user.user_id;
        }
    }];
    
    [[QNGiftService sharedInstance] getGiftModelById:model.gift_id complete:^(QNGiftModel * _Nonnull giftModel) {
        if (giftModel) {
            self.messageLabel.text = [NSString stringWithFormat:@"送出%@", giftModel.name];
            [self.giftImageView sd_setImageWithURL:[NSURL URLWithString:giftModel.img]];
        }
    }];
    
    self.contentLayer.bounds = self.contentView.bounds;
    self.contentLayer.frame = self.contentView.bounds;
}

- (void)updateContentView {
    UIColor *color1 = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    UIColor *color2 = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.05];
    
    switch (self.mode) {
        case 3:
            color1 = [UIColor colorWithRed:239.0 / 255 green:65.0 / 255 blue:73.0 / 255 alpha:0.75];
            color2 = [UIColor colorWithRed:239.0 / 255 green:65.0 / 255 blue:73.0 / 255 alpha:0.75];
            break;
            
        case 2:
            color1 = [UIColor colorWithRed:0.0 green:170.0 / 255 blue:231.0 / 255 alpha:0.75];
            color2 = [UIColor colorWithRed:0.0 green:170.0 / 255 blue:231.0 / 255 alpha:0.20];
            break;
            
        default:
            break;
    }
    
    self.contentLayer.colors = [NSArray arrayWithObjects:(id)[color1 CGColor],(id)[color2 CGColor],nil];
}

#pragma mark - SubViews
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        [_contentView.layer setCornerRadius:20.0];
        [_contentView.layer setMasksToBounds:YES];
        
        [_contentView.layer addSublayer:self.contentLayer];
    }
    return _contentView;
}

- (CAGradientLayer *)contentLayer {
    if (!_contentLayer) {
        UIColor *color1 = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
        UIColor *color2 = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.05];
        
        _contentLayer = [CAGradientLayer layer];
        _contentLayer.colors = [NSArray arrayWithObjects:(id)[color1 CGColor],(id)[color2 CGColor],nil];
        _contentLayer.startPoint = CGPointMake(0.0, 0.5);
        _contentLayer.endPoint = CGPointMake(1.0, 0.5);
        _contentLayer.borderWidth = 0;
    }
    
    return _contentLayer;
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
