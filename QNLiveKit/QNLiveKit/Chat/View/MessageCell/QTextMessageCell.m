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
        
        [self makeConstraints];
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
    
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(198);
        make.left.equalTo(self.bgView).offset(6);
        make.top.equalTo(self.nameLabel.mas_bottom);
        make.right.equalTo(self.bgView).offset(-6);
        make.bottom.equalTo(self.bgView).offset(-4);
    }];
}

- (void)setDataModel:(QNIMMessageObject *)model {
    [super setDataModel:model];
    [self updateUI:model];
}

- (void)updateUI:(QNIMMessageObject *)model {
    
    QIMModel *imModel = [QIMModel mj_objectWithKeyValues:model.content.mj_keyValues];
    PubChatModel *msgmodel = [PubChatModel mj_objectWithKeyValues:imModel.data];
            
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:msgmodel.sendUser.avatar] placeholderImage:[UIImage imageNamed:@"titleImage"]];
    
    self.nameLabel.text = msgmodel.sendUser.nick;
    
    NSString *text = msgmodel.content;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:4];//设置距离
    
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
    [attrText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, text.length)];
    [attrText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text.length)];
    [self.textLabel setAttributedText:attrText];
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    CGRect cellFrame = layoutAttributes.frame;
    if ([self.textLabel.text isEqualToString:@""]) {
        cellFrame.size.height = 44;
    } else {
        NSAttributedString *text = self.textLabel.attributedText;
        
        CGFloat textWidth = cellFrame.size.width - 40;
        CGSize size = CGSizeMake(textWidth, CGFLOAT_MAX);
        
        NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        CGRect rect = [text boundingRectWithSize:size options:options context:nil];
        
        CGFloat textHeight = ceilf(rect.size.height) + 4;
        cellFrame.size.height = textHeight + 26;
    }
    
    layoutAttributes.frame = cellFrame;
    return layoutAttributes;
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
