//
//  QNPublicChatService.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import <QNLiveKit/QNLiveKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PubChatModel;

@protocol QNPublicChatServiceLister <NSObject>
//收到公聊消息
- (void)onReceivePublicChat:(PubChatModel *)model;

@end

@interface QNPublicChatService : QNLiveService
//添加监听
- (void)addPublicChatServiceLister:(id<QNPublicChatServiceLister>)listener;

//移除监听
- (void)removePublicChatServiceLister:(id<QNPublicChatServiceLister>)listener;

//发送 聊天室聊天
- (void)sendPublicChat:(NSString *)msg callBack:(void (^)(PubChatModel * model))callBack;

//发送 欢迎进入消息
- (void)sendWelCome:(NSString *)msg callBack:(void (^)(PubChatModel * model))callBack;

//发送 拜拜
- (void)sendByeBye:(NSString *)msg callBack:(void (^)(PubChatModel * model))callBack;

//点赞
- (void)sendLike:(NSString *)msg callBack:(void (^)(PubChatModel * model))callBack;

//自定义要显示在公屏上的消息
- (void)sendCustomPubChat:(NSString *)action msg:(NSString *)msg extensions:(NSString *)extensions callBack:(void (^)(PubChatModel * model))callBack;

//往本地公屏插入消息 不发送到远端
- (void)pubLocalMsg:(PubChatModel *)chatModel;

@end

NS_ASSUME_NONNULL_END
