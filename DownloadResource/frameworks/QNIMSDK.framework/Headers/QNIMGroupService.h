//
//  QNIMGroupOption.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/6/15.
//

#import <Foundation/Foundation.h>
#import "QNIMGroupServiceProtocol.h"
#import "QNIMError.h"
#import "QNIMGroup.h"
#import "QNIMCreatGroupOption.h"
#import "QNIMGroupInvitation.h"


NS_ASSUME_NONNULL_BEGIN

@class QNIMGroupSharedFile;
@class QNIMGroupBannedMember;

@interface QNIMGroupService : NSObject

- (void)addDelegate:(id<QNIMGroupServiceProtocol>)aDelegate;

- (void)addDelegate:(id<QNIMGroupServiceProtocol>)aDelegate delegateQueue:(dispatch_queue_t)aQueue;

- (void)removeDelegate:(id<QNIMGroupServiceProtocol>)aDelegate;

+ (instancetype)sharedOption;

/**
 加入聊天室
 */
- (void)joinGroupWithGroupId:(NSString *)groupId
          message:(NSString *)message
       completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 退出聊天室
 */
- (void)leaveGroupWithGroupId:(NSString *)groupId
        completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 获取聊天室信息

 @param groupId  群id
 @param forceRefresh 如果设置了forceRefresh则从服务器拉取
 @param aCompletionBlock 群
 */
- (void)getGroupInfoByGroupId:(long long)groupId
                 forceRefresh:(BOOL)forceRefresh
                   completion:(void(^)(QNIMGroup *group,
                                       QNIMError *error))aCompletionBlock;

/**
 获取群组列表

 @param forceRefresh 如果设置了forceRefresh则从服务器拉取
 @param aCompletionBlock GroupList, Error
 */
- (void)getGroupListForceRefresh:(BOOL)forceRefresh
                      completion:(void(^)(NSArray *groupList,
                                          QNIMError *error))aCompletionBlock;


/**
 * 获取传入群组id的群组信息列表，如果设置了forceRefresh则从服务器拉取
 **/
- (void)getGroupInfoByGroupIdArray:(NSArray<NSNumber *> *)groupIdArray
                      forceRefresh:(BOOL)forceRefresh
                        completion:(void (^)(NSArray *aGroups, QNIMError *aError))aCompletionBlock;

/**
 通过群名称查询本地群信息，从本地数据库中通过群名称查询获取群组

 @param name 查询的群名称关键字
 @param aCompletionBlock  搜索结果返回的群列表信息,QNIMErrorCode
 */
- (void)getGroupByName:(NSString *)name
            completion:(void(^)(NSArray *groupList,
                                QNIMError *error))aCompletionBlock;

/**
 创建群

 @param option QNIMCreatGroupOption
 @param aCompletionBlock Group info ,Error
 */
- (void)creatGroupWithCreateGroupOption:(QNIMCreatGroupOption *)option
                             completion:(void(^)(QNIMGroup *group,
                                                 QNIMError *error))aCompletionBlock;

/**
 销毁群(群主权限)
 */
- (void)destroyGroupWithGroupId:(NSString *)groupId
          completion:(void(^)(QNIMError *error))aCompletionBlock;


/**
 获取群详情，从服务端拉取最新信息
 */
- (void)loadGroupInfoWithGroupId:(NSString *)groupId
          completion:(void(^)(QNIMGroup *group, QNIMError *error))aCompletionBlock;


/**
 * 批量获取群组成员昵称
 **/
- (void)getMembersNickNameWithGroupId:(NSString *)groupId
              memberIdlist:(NSArray<NSNumber *> *)memberIdlist
                completion:(void (^)(NSArray *aGroupMembers, QNIMError *aError))aCompletionBlock;



/**
 分页获取群组邀请列表

 @param cursor string
 @param pageSize int
 @param aCompletionBlock NSArray<QNIMGroupInvitation *> *invitationList,
 */
- (void)getInvitationListByCursor:(NSString *)cursor
                         pageSize:(int)pageSize
               completion:(void(^)(NSArray *invitationList,
                                   NSString *cursor,
                                   long long offset,
                                   QNIMError *error))aCompletionBlock;



/**
 * 分页获取群组申请列表
 **/
- (void)getApplicationListByCursor:(NSString *)cursor
                             pageSize:(int)pageSize
                           completion:(void(^)(NSArray *applicationList,
                                               NSString *cursor,
                                               long long offset,
                                               QNIMError *error))aCompletionBlock;

/**
 分页获取群成员列表
 */
- (void)getMemberListWithGroupId:(NSString *)groupId
               cursor:(NSString *)cursor
             pageSize:(int)pageSize
           completion:(void(^)(NSArray *memberList,
                               NSString *cursor,
                               long long offset,
                               QNIMError *error))aCompletionBlock;



/**
 获取群成员列表，

 @param groupId QNIMGroup Id
 @param forceRefresh 如果设置了forceRefresh则从服务器拉取，最多拉取1000人
 @param aCompletionBlock List:QNIMGroupMember ,QNIMError
 */
- (void)getMembersWithGroupId:(NSString *)groupId
      forceRefresh:(BOOL)forceRefresh
        completion:(void(^)(NSArray<QNIMGroupMember *> *groupList,
                            QNIMError *error))aCompletionBlock;

/**
  添加群成员
 */
- (void)addMembersToGroupWithGroupId:(NSString *)groupId
               memberIdlist:(NSArray<NSNumber *> *)memberIdlist
                  message:(NSString *)message
               completion:(void(^)(QNIMError *error))aCompletionBlock;


/**
 删除群成员
 */
- (void)removeMembersWithGroupId:(NSString *)groupId
                    memberlist:(NSArray<NSNumber *> *)memberList
                        reason:(NSString *)reason
                    completion:(void(^)(QNIMError *error))aCompletionBlock;


/**
  添加管理员
 */
- (void)addAdminsWithGroupId:(NSString *)groupId
           admins:(NSArray<NSNumber *> *)admins
          message:(NSString *)message
       completion:(void(^)(QNIMError *error))aCompletionBlock;


/**
 删除管理员
 */
- (void)removeAdminsWithGroupId:(NSString *)groupId
              admins:(NSArray<NSNumber *> *)admins
              reason:(NSString *)reason
          completion:(void(^)(QNIMError *error))aCompletionBlock;


/**
  获取Admins列表，如果设置了forceRefresh则从服务器拉取
 */
- (void)getAdminsWithGroupId:(NSString *)groupId
     forceRefresh:(BOOL)forceRefresh
       completion:(void(^)(NSArray<QNIMGroupMember *> *groupMember,QNIMError *error))aCompletionBlock;

/**
 * 添加黑名单
 **/
- (void)blockMembersWithGroupId:(NSString *)groupId
             members:(NSArray <NSNumber *>*)members
          completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 从黑名单删除
 **/
- (void)unblockMemberWithGroupId:(NSString *)groupId
              members:(NSArray<NSNumber *>*)members
           completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
  分页获取黑名单

 @param cursor string
 @param pageSize int
 @param aCompletionBlock NSArray<QNIMGroupMember *> *memberList,
 */
- (void)getBlockListWithGroupId:(NSString *)groupId
                    cursor:(NSString *)cursor
                 pageSize:(int)pageSize
               completion:(void(^)(NSArray *memberList,
                                   NSString *cursor,
                                   long long offset,
                                   QNIMError *error))aCompletionBlock;


/**
 * 获取黑名单
 **/
- (void)getBlockListWithGroupId:(NSString *)groupId
        forceRefresh:(BOOL)forceRefresh
          completion:(void(^)(NSArray<QNIMGroupMember *> *groupMember,QNIMError *error))aCompletionBlock;

/**
 * 禁言
 **/
- (void)banMembers:(NSArray <NSNumber *>*)members
            groupId:(NSString *)groupId
             reason:(NSString *)reason
           duration:(long long)duration
         completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 解除禁言
 **/
- (void)unbanMembersWithGroupId:(NSString *)groupId
                     members:(NSArray <NSNumber *>*)members
                      reason:(NSString *)reason
                  completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 分页获取禁言列表

 @param cursor string
 @param pageSize int
 @param aCompletionBlock NSArray<QNIMGroupMember *> *memberList
 */
- (void)getbannedMemberListWithGroupId:(NSString *)groupId
                        cursor:(NSString *)cursor
                      pageSize:(int)pageSize
                    completion:(void(^)(NSArray *memberList,
                                        NSString *cursor,
                                        long long offset,
                                        QNIMError *error))aCompletionBlock;



/**
 * 获取禁言列表
 **/
- (void)getBannedMembersWithGroupId:(NSString *)groupId
                    completion:(void(^)(NSArray<QNIMGroupBannedMember *> *bannedMemberList,
                                        QNIMError *error))aCompletionBlock;
/**
 * 屏蔽群消息
 **/
- (void)muteMessageWithGroupId:(NSString *)groupId
               msgMuteMode:(QNIMGroupMsgMuteMode)msgMuteMode
                completion:(void(^)(QNIMError *error))aCompletionBlock;



/**
 * 接受入群申请
 **/
- (void)acceptApplicationWithGroupId:(NSString *)groupId
                     applicantId:(long long)applicantId
                      completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 拒绝入群申请
 **/
- (void)declineApplicationWithGroupId:(NSString *)groupId
                      applicantId:(long long)applicantId
                       completion:(void(^)(QNIMError *error))aCompletionBlock;
/**
 * 接受入群邀请
 **/
- (void)acceptInvitationWithGroupId:(NSString *)groupId
                        inviter:(long long)inviter
                     completion:(void(^)(QNIMError *error))aCompletionBlock;


/**
 * 拒绝入群邀请
 **/
- (void)declineInvitationWithGroupId:(NSString *)groupId
                         inviter:(long long)inviter
                      completion:(void(^)(QNIMError *error))aCompletionBlock;



/**
 * 转移群主
 **/
- (void)transferOwnerWithGroupId:(NSString *)groupId
                  newOwnerId:(long long)newOwnerId
                  completion:(void(^)(QNIMError *error))aCompletionBlock;


/**
 * 添加群共享文件
 **/
- (void)uploadSharedFileWithGroupId:(NSString *)groupId
                    filePathStr:(NSString *)filePathStr
                    displayName:(NSString *)displayName
                     extionName:(NSString *)extionName
                       progress:(void(^)(int progress, QNIMError *error))aProgress
                     completion:(void(^)(QNIMGroup *resultGroup, QNIMError *error))aCompletion;

/**
 * 移除群共享文件
 **/
- (void)removeSharedFileWithGroupId:(NSString *)groupId
                             file:(QNIMGroupSharedFile *)file
                       completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 下载群共享文件
 **/
- (void)downloadSharedFileWithGroupId:(NSString *)groupId
                          shareFile:(QNIMGroupSharedFile *)shareFile
                           progress:(void(^)(int progress, QNIMError *error))aProgress
                         completion:(void(^)(QNIMGroup *resultGroup, QNIMError *error))aCompletion;

/**
 * 获取群共享文件列表
 **/
- (void)getSharedFilesListWithGroupId:(NSString *)groupId
                     forceRefresh:(BOOL)forceRefresh
                       completion:(void(^)(NSArray<QNIMGroupSharedFile *> *sharedFileList, QNIMError *error))aCompletionBlock;


/**
 * 获取最新的群公告
 **/
- (void)getLatestAnnouncementWithGroupId:(NSString *)groupId
                          forceRefresh:(BOOL)forceRefresh
                            completion:(void(^)(QNIMGroupAnnounment *groupAnnounment, QNIMError *error))aCompletionBlock;

/**
 * 获取群公告列表
 **/
- (void)getAnnouncementListWithGroupId:(NSString *)groupId
                        forceRefresh:(BOOL)forceRefresh
                          completion:(void(^)(NSArray *annoucmentArray, QNIMError *error))aCompletionBlock;

/**
 * 设置群公告
 **/
- (void)editGroupAnnouncementWithGroupId:(NSString *)groupId
                        title:(NSString *)title
                      content:(NSString *)content
                   completion:(void(^)(QNIMGroup *group, QNIMError *error))aCompletionBlock;


/**
 * 删除群公告
 **/
- (void)deleteAnnouncementWithGroupId:(NSString *)groupId
                     announcementId:(long long)announcementId
                         completion:(void(^)(QNIMGroup *group, QNIMError *error))aCompletionBlock;

/**
 * 设置群名称
 **/
- (void)setGroupNameWithGroupId:(NSString *)groupId
                name:(NSString *)name
          completion:(void(^)(QNIMGroup *group,QNIMError *error))aCompletionBlock;

/**
 * 设置群描述信息
 **/
- (void)setGroupDescriptionWithGroupId:(NSString *)groupId
           description:(NSString *)description
            completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 设置群扩展信息
 **/
- (void)setGroupExtensionWithGroupId:(NSString *)groupId
                         extension:(NSString *)extension
                        completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 设置在群里的昵称
 **/
- (void)setMyNicknameWithGroupId:(NSString *)groupId
                      nickName:(NSString *)nickName
                    completion:(void(^)(QNIMError *error))aCompletionBlock ;

/**
 * 设置群消息通知模式
 **/
- (void)setMsgPushModeWithGroupId:(NSString *)groupId
                          mode:(QNIMGroupMsgPushMode)mode
                    completion:(void(^)(QNIMError *error))aCompletionBlock ;

/**
 * 设置入群审批模式
 **/
- (void)setJoinAuthModeWithGroupId:(NSString *)groupId
                    joinAuthMode:(QNIMGroupJoinAuthMode)mode
                      completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 设置邀请模式
 **/
- (void)setInviteModeWithGroupId:(NSString *)groupId
                          mode:(QNIMGroupInviteMode)inviteMode
                    completion:(void(^)(QNIMError *error))aCompletionBlock;


/**
 设置是否允许群成员设置群信息

 @param groupId 进行操作的群组
 @param enable 是否允许操作
 @param aCompletionBlock  QNIMError
 */
- (void)setAllowMemberModifyWithGroupId:(NSString *)groupId
                                enable:(BOOL)enable
                           completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
设置是否开启群消息已读功能

 @param groupId 进行操作的群组
 @param enable 是否开启
 @param aCompletionBlock QNIMError
 */
- (void)setEnableReadAckWithGroupId:(NSString *)groupId
                           enable:(BOOL)enable
                       completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 设置群成员是否开可见群历史聊天记录

 @param groupId 进行操作的群组
 @param enable 是否开启
 @param aCompletionBlock QNIMError
 */
- (void)setHistoryVisibleWithGroupId:(NSString *)groupId
                            enable:(BOOL)enable
                        completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 设置群头像
 **/
- (void)setAvatarWithGroupId:(NSString *)groupId
                avatarData:(NSData *)avatarData
                  progress:(void(^)(int progress, QNIMError *error))aProgress
                completion:(void(^)(QNIMGroup *resultGroup, QNIMError *error))aCompletion;

/**
 * 下载群头像
 **/
- (void)downloadAvatarWithGroupId:(NSString *)groupId
                        progress:(void(^)(int progress, QNIMError *error))aProgress
                      completion:(void(^)(QNIMGroup *resultGroup, QNIMError *error))aCompletion;


/**
 * 添加群组变化监听者
 **/
- (void)addGroupListener:(id<QNIMGroupServiceProtocol>)listener;

/**
 * 移除群组变化监听者
 **/
- (void)removeGroupListener:(id<QNIMGroupServiceProtocol>)listener;



@end

NS_ASSUME_NONNULL_END
