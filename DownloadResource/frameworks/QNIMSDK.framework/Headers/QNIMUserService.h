//
//  QNIMUserService.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>
#import "QNIMDefines.h"
#import "QNIMUserServiceProtocol.h"
#import "QNIMUserProfile.h"
@class QNIMMessageSetting;
@class QNIMError;

NS_ASSUME_NONNULL_BEGIN

@interface QNIMUserService : NSObject

- (void)addDelegate:(id<QNIMUserServiceProtocol>)aDelegate;

- (void)addDelegate:(id<QNIMUserServiceProtocol>)aDelegate delegateQueue:(dispatch_queue_t)aQueue;

- (void)removeDelegate:(id<QNIMUserServiceProtocol>)aDelegate;

+ (instancetype)sharedOption;

/**
 * 绑定设备推送token
 **/
- (void)bindDevice:(NSString *)token
        completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 获取设备列表
 */
- (void)getDeviceListCompletion:(void(^)(QNIMError *error,NSArray *deviceList))aCompletionBlock;
/**
 * 删除设备
 */
- (void)deleteDeviceByDeviceSN:(NSInteger)deviceSN
                    completion:(void(^)(QNIMError *error))aCompletionBlock;
/**
 * 获取用户详情
 **/
- (void)getProfileForceRefresh:(BOOL)forceRefresh
                    completion:(void (^)(QNIMUserProfile *profile ,QNIMError *aError))aCompletionBlock;

/**
 * 设置昵称
 **/
- (void)setNickname:(NSString *)nickname completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 上传头像

 @param avatarData 头像
 @param aProgressBlock 上传进度
 */
- (void)uploadAvatarWithData:(NSData *)avatarData
                    progress:(void(^)(int progress, QNIMError *error))aProgressBlock;


/**
 下载头像

 @param profile 用户信息
 @param aProgress 下载进度
 @param aCompletion 回调
 */
- (void)downloadAvatarWithProfile:(QNIMUserProfile *)profile
                        thumbnail:(BOOL)thumbnail
                         progress:(void(^)(int progress, QNIMError *error))aProgress
                       completion:(void(^)(QNIMUserProfile *profile, QNIMError *error))aCompletion;

/**
 设置公开扩展信息

 @param publicInfo string
 */
- (void)setPublicInfo:(NSString *)publicInfo
           completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 设置私有扩展信息

 @param privateInfo string
 */
- (void)setPrivateInfo:(NSString *)privateInfo
            completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 设置加好友验证方式

 @param addFriendAuthMode QNIMAddFriendAuthMode
 */
- (void)setAddFriendAuthMode:(QNIMAddFriendAuthMode)addFriendAuthMode
                  completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
设置加好友验证问题

 @param authQuestion QNIMAuthQuestion
 */
- (void)setAuthQuestion:(QNIMAuthQuestion *)authQuestion
             completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 设置是否允许推送

 @param enablePushStatus BOOL
 */
- (void)setEnablePushStatus:(BOOL)enablePushStatus
                 completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 设置是否推送详情

 @param enablePushDetail BOOL
 */
- (void)setEnablePushDetail:(BOOL)enablePushDetail
                       completion:(void(^)(QNIMError *error))aCompletionBlock;
/**
 * 设置推送昵称
 **/
- (void)setsetPushNickname:(NSString *)nickname
                completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 设置收到新消息是否声音提醒
 
 @param notificationSound BOO
 */
- (void)setNotificationSound:(BOOL)notificationSound
                  completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 设置收到新消息是否震动
 
 @param notificationVibrate BOOL
 */
- (void)setNotificationVibrate:(BOOL)notificationVibrate
                    completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 设置是否自动缩略图和语音附件

 @param autoDownloadAttachment BOOL
 */
- (void)setAutoDownloadAttachment:(BOOL)autoDownloadAttachment
                       completion:(void(^)(QNIMError *error))aCompletionBlock;
/**
 设置是否自动同意入群邀请

 @param autoAcceptGroupInvite BOOL
 */
- (void)setAutoAcceptGroupInvite:(BOOL)autoAcceptGroupInvite
                      completion:(void(^)(QNIMError *error))aCompletionBlock;


@end

NS_ASSUME_NONNULL_END
