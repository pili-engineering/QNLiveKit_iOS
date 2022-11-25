//
//  QMessageBaseCell.h
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/10.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QNIMSDK/QNIMSDK.h>

//#import "QNIMTextMsgModel.h"

@interface QMessageBaseCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *avatarImageView;

@property (nonatomic, strong) UIView *bgView;

/**
 消息Cell的数据模型
 */
@property(strong, nonatomic) QNIMMessageObject *model;

/**
 设置当前消息Cell的数据模型
 
 @param model 消息Cell的数据模型
 */
- (void)setDataModel:(QNIMMessageObject *)model;

/**
 更新layout
 */
- (void)makeConstraints;

@end
