//
//  QNTextMessageCell.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/22.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "QNTextMessageCell.h"
#import "PubChatModel.h"
#import "QNIMModel.h"
#import <Masonry/Masonry.h>
#import <QNIMSDK/QNIMSDK.h>
#import <SDWebImage/SDWebImage.h>

#define RCCRText_HEXCOLOR(rgbValue)                                                                                             \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0                                               \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0                                                  \
blue:((float)(rgbValue & 0xFF)) / 255.0                                                           \
alpha:1.0]

@interface QNTextMessageCell ()

@end

@implementation QNTextMessageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initializedSubViews];
    }
    return self;
}

- (void)initializedSubViews {
    [self avatarImageView];
    [self bgView];
    [self nameLabel];
    [self textLabel];

}

- (void)setDataModel:(QNIMMessageObject *)model {
    [super setDataModel:model];
    [self updateUI:model];
}

- (void)updateUI:(QNIMMessageObject *)model {
    
    PubChatModel *msgmodel = [PubChatModel mj_objectWithKeyValues:model.content];
            
    self.nameLabel.text = msgmodel.sendUser.nick;
    self.textLabel.text = msgmodel.content;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:msgmodel.sendUser.avatar] placeholderImage:[UIImage imageNamed:@"titleImage"]];
        
}

+ (CGSize)getMessageCellSize:(NSString *)content withWidth:(CGFloat)width{
    CGSize textSize = CGSizeZero;
    textSize.height = textSize.height + 17 + 20;
    return textSize;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        [_textLabel setTextAlignment: NSTextAlignmentLeft];
        [_textLabel setTextColor:[UIColor whiteColor]];
        _textLabel.numberOfLines = 0;
        [_textLabel setFont:[UIFont systemFontOfSize:13]];
        [self.bgView addSubview:_textLabel];
        
        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel);
            make.right.equalTo(self.bgView.mas_right).offset(-5);
            make.top.equalTo(self.nameLabel.mas_bottom).offset(3);
            make.bottom.equalTo(self.bgView).offset(-5);
        }];
    }
    return _textLabel;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha = 0.6;
        _bgView.layer.cornerRadius = 5;
        [self addSubview:_bgView];
        
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(50);
            make.top.equalTo(self);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(self).offset(-5);
        }];
    }
    return _bgView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        [_nameLabel setTextAlignment: NSTextAlignmentLeft];
        [_nameLabel setTextColor:[UIColor colorWithRed:0.8 green:0.875 blue:0.988 alpha:1]];
        [_nameLabel setFont:[UIFont systemFontOfSize:13]];
        [self.bgView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bgView.mas_left).offset(8);
            make.top.equalTo(self.avatarImageView);
            make.right.equalTo(self.bgView.mas_right).offset(-5);
            make.height.mas_equalTo(20);
        }];
    }
    return _nameLabel;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc]init];
        [self addSubview:_avatarImageView];
        _avatarImageView.backgroundColor = [UIColor yellowColor];
        _avatarImageView.layer.cornerRadius = 12;
        _avatarImageView.clipsToBounds = YES;
        [_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.top.equalTo(self);
            make.width.height.mas_equalTo(30);
        }];
    }
    return _avatarImageView;
}

- (NSString *)timeWithTimeInterval:(long)timeInterval
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInterval/ 1000.0];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}

@end
