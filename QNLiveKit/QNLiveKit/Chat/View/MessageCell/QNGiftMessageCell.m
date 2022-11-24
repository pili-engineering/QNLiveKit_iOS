//
//  QNGiftMessageCell.m
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/23.
//

#import "QNGiftMessageCell.h"
#import "QIMModel.h"
#import "QNGiftMsgModel.h"
#import "QNUserService.h"
#import "QNGiftService.h"

@interface QNGiftMessageCell ()

@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) QNLiveUser *user;
@property (nonatomic, strong) QNGiftMsgModel *giftMsgModel;
@property (nonatomic, strong) QNGiftModel *giftModel;

@end

@implementation QNGiftMessageCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.textLabel];
    }
    
    return self;
}

- (void)makeConstraints {
    [super makeConstraints];
    
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(6);
        make.top.equalTo(self.bgView).offset(4);
        
        make.right.equalTo(self.bgView).offset(-6);
        make.bottom.equalTo(self.bgView).offset(-4);
    }];
}

+ (CGSize)getMessageCellSize:(NSString *)content withWidth:(CGFloat)width {
    return CGSizeMake(width, 40);
}

- (void)setDataModel:(QNIMMessageObject *)model {
    [super setDataModel:model];
    [self updateUI:model];
}

- (void)updateUI:(QNIMMessageObject *)model {
    
    QIMModel *imModel = [QIMModel mj_objectWithKeyValues:model.content.mj_keyValues];
    QNGiftMsgModel *giftMsgModel = [QNGiftMsgModel mj_objectWithKeyValues:imModel.data];
    self.giftMsgModel = giftMsgModel;
    
    [[QNUserService sharedInstance] getUserByID:giftMsgModel.user_id complete:^(QNLiveUser * user) {
        if (user) {
            [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"titleImage"]];
            self.user = user;
            
            [self updateContent];
        }
    }];
    
    [[QNGiftService sharedInstance] getGiftModelById:giftMsgModel.gift_id complete:^(QNGiftModel * giftModel) {
        if (giftModel) {
            self.giftModel = giftModel;
            
            [self updateContent];
        }
    }];
}

- (void) updateContent {
    if (self.user && self.giftModel) {
        NSString *nick = self.user.nick ? self.user.nick : self.user.user_id;
        NSString *gift = self.giftModel.amount > 0 ? self.giftModel.name : [NSString stringWithFormat:@"%@ %ld", self.giftModel.name, self.giftMsgModel.amount];
        NSString *text = [NSString stringWithFormat:@"%@ 打赏 %@", nick, gift];
        self.textLabel.text = text;
        
        NSRange giftRange;
        giftRange.length = gift.length;
        giftRange.location = text.length - giftRange.length;
        
        NSRange actionRange;
        actionRange.length = 2;
        actionRange.location = giftRange.location - 3;
        
        NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
        [attrText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#F3CF22"] range:giftRange];
        [attrText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:actionRange];
        
        self.textLabel.attributedText = attrText;
    } else {
        self.textLabel.text = @"";
    }
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        [_textLabel setFont:[UIFont systemFontOfSize:13]];
        [_textLabel setTextColor:[UIColor colorWithHexString:@"#CCDFFC"]];
        
        [_textLabel setTextAlignment: NSTextAlignmentLeft];
        _textLabel.numberOfLines = 0;
        
    }
    return _textLabel;
}
@end
