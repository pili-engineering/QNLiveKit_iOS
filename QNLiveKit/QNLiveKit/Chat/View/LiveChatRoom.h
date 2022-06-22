//
//  LiveChatRoom.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/2.
//

#import <UIKit/UIKit.h>
#import "QNInputBarControl.h"
#import <QNIMSDK/QNIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LiveChatRoomViewDelegate <NSObject>
@optional
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
@property(nonatomic,strong) QNInputBarControl *inputBar;

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

- (void)sendMessage:(QNIMMessageObject *)messageContent;
//展示message
- (void)showMessage:(QNIMMessageObject *)message;

- (void)alertErrorWithTitle:(NSString *)title message:(NSString *)message ok:(NSString *)ok;

- (instancetype)initWithFrame:(CGRect)frame ;

- (void)setDefaultBottomViewStatus;


@end

NS_ASSUME_NONNULL_END
