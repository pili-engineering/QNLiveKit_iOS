//
//  QNTextMessageCell.h
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/22.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "QNMessageBaseCell.h"

#define TextMessageFontSize 16

@interface QNTextMessageCell : QNMessageBaseCell

/*!
 显示消息内容的Label
 */
@property(nonatomic, strong) UILabel *textLabel;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIView *bgView;

+ (CGSize)getMessageCellSize:(NSString *)content withWidth:(CGFloat)width;

@end
