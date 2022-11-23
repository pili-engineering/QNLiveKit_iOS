//
//  QTextMessageCell.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/22.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "QTextMessageCell.h"
#import "PubChatModel.h"
#import "QIMModel.h"
#import <Masonry/Masonry.h>
#import <QNIMSDK/QNIMSDK.h>
#import <SDWebImage/SDWebImage.h>


@interface QTextMessageCell ()

@end

@implementation QTextMessageCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.textLabel];
    }
    return self;
}

- (void)makeConstraints {
    [super makeConstraints];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(18);
        make.left.equalTo(self.bgView).offset(6);
        make.top.equalTo(self.bgView).offset(4);
    }];
    
//    [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.nameLabel);
//        make.right.equalTo(self.bgView.mas_right).offset(-5);
//        make.top.equalTo(self.nameLabel.mas_bottom).offset(3);
//        make.bottom.equalTo(self.bgView).offset(-5);
//    }];
    
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(6);
        make.top.equalTo(self.nameLabel.mas_bottom);
        make.right.equalTo(self.bgView).offset(-6);
        make.bottom.equalTo(self.bgView).offset(-4);
    }];
    
//    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.bgView.mas_left).offset(8);
//        make.top.equalTo(self.avatarImageView);
//        make.right.equalTo(self.bgView.mas_right).offset(-5);
//        make.height.mas_equalTo(20);
//    }];
}

- (void)setDataModel:(QNIMMessageObject *)model {
    [super setDataModel:model];
    [self updateUI:model];
}

- (void)updateUI:(QNIMMessageObject *)model {
    
    QIMModel *imModel = [QIMModel mj_objectWithKeyValues:model.content.mj_keyValues];
    PubChatModel *msgmodel = [PubChatModel mj_objectWithKeyValues:imModel.data];
            
    self.nameLabel.text = msgmodel.sendUser.nick;
    self.textLabel.text = msgmodel.content;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:msgmodel.sendUser.avatar] placeholderImage:[UIImage imageNamed:@"titleImage"]];
        
}

+ (CGSize)getMessageCellSize:(NSString *)content withWidth:(CGFloat)width{
    return CGSizeMake(width, 44);
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

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        
        [_nameLabel setFont:[UIFont systemFontOfSize:13]];
        [_nameLabel setTextColor:[UIColor colorWithHexString:@"#CCDFFC"]];
        
        [_nameLabel setTextAlignment: NSTextAlignmentLeft];
        [_nameLabel setNumberOfLines:1];
    }
    return _nameLabel;
}

//- (NSString *)timeWithTimeInterval:(long)timeInterval
//{
//    // 格式化时间
//    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
//    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
//    [formatter setDateStyle:NSDateFormatterMediumStyle];
//    [formatter setTimeStyle:NSDateFormatterShortStyle];
//    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
//
//    // 毫秒值转化为秒
//    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInterval/ 1000.0];
//    NSString* dateString = [formatter stringFromDate:date];
//    return dateString;
//}

@end
