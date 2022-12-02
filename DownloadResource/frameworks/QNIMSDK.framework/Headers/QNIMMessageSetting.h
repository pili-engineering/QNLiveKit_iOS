//
//  QNIMMessageSetting.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNIMMessageSetting : NSObject
/**
 推送开关
 */
@property (nonatomic,assign, readonly) BOOL mPushEnabled;

/**
 推送详情
 */
@property (nonatomic,assign, readonly) BOOL mPushDetail;

/**
 对方收到推送消息时显示的名称
 */
@property (nonatomic,copy) NSString *pushNickname;

/**
 推送声音
 */
@property (nonatomic,assign, readonly) BOOL mNotificationSound;

/**
 推送通知震动
 */
@property (nonatomic,assign, readonly) BOOL mNotificationVibrate;

/**
 自动下载附件
 */
@property (nonatomic,assign, readonly) BOOL mAutoDownloadAttachment;


@property (nonatomic,assign) int silenceStartTime;

@property (nonatomic, assign) int silenceEndTime;

@property (nonatomic,assign) int  pushStartTime;

@property (nonatomic, assign) int mPushEndTime;

@end

NS_ASSUME_NONNULL_END
