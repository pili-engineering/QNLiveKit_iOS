//
//  LiveChatRoom.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/2.
//

#import <UIKit/UIKit.h>
#import "QInputBarControl.h"

NS_ASSUME_NONNULL_BEGIN

@class QNIMMessageObject;

@protocol LiveChatRoomViewDelegate <NSObject>
@optional
//消息文本编辑完成  return 是否需要发送
- (BOOL)didEndEditMessageContent:(NSString *)content;
//消息发送完成
-(void)didSendMessageModel:(QNIMMessageObject *)model;

@end

@interface LiveChatRoom : UIView

@property(nonatomic, weak) id<LiveChatRoomViewDelegate> delegate;

@property(nonatomic, copy) NSString *groupId;

/*!
 消息列表CollectionView和输入框都在这个view里
 */
@property(nonatomic, strong) UIView *messageContentView;

/*!
 会话页面的CollectionView
 */
@property(nonatomic, strong) UICollectionView *conversationMessageCollectionView;

/**
 输入工具栏
 */
@property(nonatomic,strong) QInputBarControl *inputBar;

/**
 底部按钮容器，底部的四个按钮都添加在此view上
 */
@property(nonatomic, strong) UIView *bottomBtnContentView;

/**
 *  评论按钮
 */
@property(nonatomic,strong)UIButton *commentBtn;

@property(nonatomic,strong) QNIMMessageObject *model;

/**
 数据模型
 */
- (void)commentBtnPressedWithPubchat:(BOOL)isPubchat;
- (void)onTouchSendButton:(NSString *)text;
//发送
- (void)sendMessage:(QNIMMessageObject *)messageContent;
//展示message
- (void)showMessage:(QNIMMessageObject *)message;

- (void)alertErrorWithTitle:(NSString *)title message:(NSString *)message ok:(NSString *)ok;

- (instancetype)initWithFrame:(CGRect)frame ;

- (void)setDefaultBottomViewStatus;


@end

NS_ASSUME_NONNULL_END
