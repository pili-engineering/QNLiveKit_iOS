//
//  QNTextMessageCell.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/22.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "QNTextMessageCell.h"
#import "QNIMTextMsgModel.h"
#import "QNIMModel.h"
#import <Masonry/Masonry.h>
#import <QNIMSDK/QNIMSDK.h>

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
    [self bgView];
    [self textLabel];

//    [_textLabel setFrame:CGRectMake(10, 0, self.bounds.size.width - 10, self.bounds.size.height)];
}

- (void)setDataModel:(QNIMMessageObject *)model {
    [super setDataModel:model];
    [self updateUI:model];
}

- (void)updateUI:(QNIMMessageObject *)model {
    
        QNIMModel *msgmodel = [QNIMModel mj_objectWithKeyValues:model.content];
        QNIMTextMsgModel *messageModel = [QNIMTextMsgModel mj_objectWithKeyValues:msgmodel.data];
            
        NSString *userName = [messageModel.senderName stringByAppendingString:@"："];
        NSString *sendMsgStr = messageModel.msgContent;
        
        NSString *str =[NSString stringWithFormat:@"%@%@",userName,sendMsgStr];
            
        self.textLabel.text = str;
        self.textLabel.textColor = [UIColor whiteColor];
        
}

+ (CGSize)getMessageCellSize:(NSString *)content withWidth:(CGFloat)width{
    CGSize textSize = CGSizeZero;
    textSize.height = textSize.height + 17;
    return textSize;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        [_textLabel setTextAlignment: NSTextAlignmentLeft];
        [_textLabel setTintColor:[UIColor whiteColor]];
        [_textLabel setNumberOfLines:0];
        [_textLabel setFont:[UIFont systemFontOfSize:13]];
        [self.bgView addSubview:_textLabel];
        
        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bgView).offset(10);
            make.right.equalTo(self.bgView).offset(-10);
            make.centerY.equalTo(self.bgView);
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
            make.left.equalTo(self).offset(20);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(25);
            make.bottom.equalTo(self).offset(-5);
        }];
    }
    return _bgView;
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
