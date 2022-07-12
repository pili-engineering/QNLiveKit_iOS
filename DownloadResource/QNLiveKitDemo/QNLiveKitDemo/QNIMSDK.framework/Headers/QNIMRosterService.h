//
//  QNIMRosterOption.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>
#import "QNIMRosterServiceProtocol.h"
#import "QNIMError.h"

@class QNIMRoster;
@class QNIMRosterManagerListener;

NS_ASSUME_NONNULL_BEGIN

@interface QNIMRosterService : NSObject

- (void)addDelegate:(id<QNIMRosterServiceProtocol>)aDelegate;

- (void)addDelegate:(id<QNIMRosterServiceProtocol>)aDelegate delegateQueue:(dispatch_queue_t)aQueue;

- (void)removeDelegate:(id<QNIMRosterServiceProtocol>)aDelegate;

+ (instancetype)sharedOption;


/**
 * 获取好友列表
 @param forceRefresh 如果forceRefresh == true，则强制从服务端拉取
 @param aCompletionBlock 好友列表
 */
- (void)getRosterListforceRefresh:(BOOL)forceRefresh
                       completion:(void (^)(NSArray *rostIdList,
                                            QNIMError *error))aCompletionBlock;

/**
 通过好友ID搜索
 @param rosterId 好友ID
 @param aCompletionBlock 好友
 */
- (void)searchByRosterId:(long long)rosterId
            forceRefresh:(BOOL)forceRefresh
              completion:(void(^)(QNIMRoster *roster,
                                  QNIMError *error))aCompletionBlock;
/**
 通过好友Name搜索
 @param name  好友name
 @param aCompletionBlock 好友
 */
- (void)searchByRoserName:(NSString *)name
             forceRefresh:(BOOL)forceRefresh
               completion:(void(^)(QNIMRoster *roster, QNIMError *error))aCompletionBlock;

/**
 批量搜索用户

 @param rosterIdList  id
 @param forceRefresh  如果forceRefresh == true，则强制从服务端拉取
 @param aCompletionBlock rosterList,error
 */
- (void)searchRostersByRosterIdList:(NSArray<NSNumber *> *)rosterIdList
                       forceRefresh:(BOOL)forceRefresh
                         completion:(void (^)(NSArray <QNIMRoster *>*rosterList,
                                              QNIMError *error))aCompletionBlock;


/**
 更新好友扩展信息
 */
- (void)updateItemExtensionByRosterId:(long long)rosterId
                      extensionJson:(NSString *)extensionJson
                         completion:(void(^)(QNIMRoster *roster,
                                             NSString *extensionJson))aCompletionBlock;
/**
 * 更新好友本地扩展信息
 **/
- (void)updateItemLocalExtensionByRosterId:(long long)rosterId
                      localExtensionJson:(NSString *)localExtensionJson
                              completion:(void(^)(QNIMRoster *roster,  QNIMError *error))aCompletionBlock;

/**
 * 更新好友别名
 **/
- (void)updateItemAliasByRosterId:(long long)rosterId
                      aliasJson:(NSString *)aliasJson
                     completion:(void(^)(QNIMRoster *roster, QNIMError *error))aCompletionBlock;

/**
 * 设置是否拒收用户消息
 **/
- (void)muteNotificationByRosterId:(long long)rosterId
          muteNotificationStatus:(BOOL)muteNotificationStatus
                      completion:(void(^)(QNIMRoster *roster,  QNIMError *error))aCompletionBlock;


/**
 * 获取申请添加好友列表
 **/
- (void)getApplicationListWithCursor:(NSString *)cursor
                            pageSize:(int)pageSize
                          completion:(void(^)(NSArray *applicationList,
                                              NSString *cursor,
                                              int offset,
                                              QNIMError *error))aCompletionBlock ;

/**
 * 申请添加好友
 **/
- (void)applyAddRosterById:(long long)rostId
                reason:(NSString *)reason
            completion:(void(^)(QNIMRoster *roster,
                                QNIMError *error))aCompletionBlock;

/**
 * 删除好友
 **/
- (void)removeRosterById:(long long)rostId
          withCompletion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 接受加好友申请
 **/
- (void)acceptRosterById:(NSInteger)rosterId
          withCompletion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 拒绝加好友申请
 **/
- (void)declineRosterById:(NSInteger)rosterId
               withReason:(NSString *)reason
               completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 加入黑名单
 **/
- (void)addToBlockList:(long long)rosterId
        withCompletion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 从黑名单移除
 **/
- (void)removeRosterFromBlockList:(NSInteger)rostId
                   withCompletion:(void(^)(QNIMError *error))aCompletionBlock;


/**
 * 下载头像
 **/
- (void)downloadAvatarByRosterId:(long long)rosterId
                        progress:(void(^)(int progress, QNIMError *error))aProgress
                      completion:(void(^)(QNIMRoster *roster, QNIMError *error))aCompletion;
/**
 * 获取黑名单
 @param forceRefresh 如果forceRefresh == true，则强制从服务端拉取
 @param aCompletionBlock BlockList ,Error
 */
- (void)getBlockListforceRefresh:(BOOL)forceRefresh
                      completion:(void(^)(NSArray *blockList,
                                          QNIMError *error))aCompletionBlock;
/**
 * 添加好友变化监听者
 **/
- (void)addRosterListener:(id<QNIMRosterServiceProtocol>)listener;

/**
 * 移除好友变化监听者
 **/
- (void)removeRosterListener:(id<QNIMRosterServiceProtocol>)listener;


@end

NS_ASSUME_NONNULL_END
