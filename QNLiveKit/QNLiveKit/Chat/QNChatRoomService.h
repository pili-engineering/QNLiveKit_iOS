//
//  QNChatRoomService.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import <QNLiveKit/QNLiveKit.h>
#import "QNLiveService.h"

NS_ASSUME_NONNULL_BEGIN

//聊天室监听
@protocol QNChatRoomServiceListener <NSObject>
//有人加入聊天室
- (void)onUserJoin:(NSString *)memberId;
//有人离开聊天室
- (void)onUserLeave:(NSString *)memberId;
//收到c2c消息
- (void)onReceivedC2CMsg:(NSString *)msg fromId:(NSString *)fromId toId:(NSString *)toId;
//收到群消息
- (void)onReceivedGroupMsg:(NSString *)msg fromId:(NSString *)fromId toId:(NSString *)toId;
//有人被踢
- (void)onUserBeKicked:(NSString *)memberId;
//有人被禁言
- (void)onUserBeMuted:(BOOL)isMuted memberId:(NSString *)memberId duration:(long long)duration;
//新增了管理员
- (void)onAdminAdd:(NSString *)memberId;
//移除了管理员
- (void)onAdminRemoved:(NSString *)memberId reason:(NSString *)reason;

@end

@interface QNChatRoomService : QNLiveService

//添加聊天监听
- (void)addChatServiceListener:(id<QNChatRoomServiceListener>)listener;

//移除聊天监听
- (void)removeChatServiceListener:(id<QNChatRoomServiceListener>)listener;

//发c2c消息
- (void)sendCustomC2CMsg:(NSString *)msg memberId:(NSString *)memberId callBack:(void (^)(void))callBack;
//发群消息
- (void)sendCustomGroupMsg:(NSString *)msg groupId:(NSString *)groupId callBack:(void (^)(void))callBack;
//踢人
- (void)kickUser:(NSString *)msg memberId:(NSString *)memberId callBack:(void (^)(void))callBack;
//禁言
- (void)muteUser:(NSString *)msg memberId:(NSString *)memberId duration:(long long)duration isMute:(BOOL)isMute callBack:(void (^)(void))callBack;
//添加管理员
- (void)addAdmin:(NSString *)memberId callBack:(void (^)(void))callBack;
//移除管理员
- (void)removeAdmin:(NSString *)msg memberId:(NSString *)memberId callBack:(void (^)(void))callBack;

@end

NS_ASSUME_NONNULL_END
