//
//  QTextMessageCell.h
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/22.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "QMessageBaseCell.h"

#define TextMessageFontSize 16

@interface QTextMessageCell : QMessageBaseCell

/*!
 显示消息内容的Label
 */
@property(nonatomic, strong) UILabel *textLabel;
@property(nonatomic, strong) UILabel *nameLabel;


@end
