//
//  QNIMGroupServiceProtocol.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/6/7.
//

#import <Foundation/Foundation.h>
#import "QNIMGroup.h"

@class QNIMGroupAnnounment;

@protocol QNIMGroupServiceProtocol <NSObject>

/**
 * 多设备同步创建群组
 **/
- (void)groupDidCreated:(QNIMGroup *)group;

/**
 退出了某群
 */
- (void)groupLeft:(QNIMGroup *)group reason:(NSString *)reason;

/**
 * 收到入群邀请
 **/
- (void)groupDidRecieveInviter:(NSInteger)inviter groupId:(NSInteger)groupId message:(NSString *)message;

/**
 * 入群邀请被接受
 **/
- (void)groupInvitationAccepted:(QNIMGroup *)group inviteeId:(NSInteger)inviteeId;

/**
 * 入群申请被拒绝
 **/
- (void)groupInvitationDeclined:(QNIMGroup *)group
                      inviteeId:(NSInteger)inviteeId
                         reason:(NSString *)reason;
/**
 * 收到入群申请
 **/
- (void)groupDidRecieveApplied:(QNIMGroup *)group
                   applicantId:(NSInteger)applicantId
                       message:(NSString *)message;

/**
 * 入群申请被接受
 **/
- (void)groupApplicationAccepted:(QNIMGroup *)group
                        approver:(NSInteger)approver;

/**
 * 入群申请被拒绝
 **/
- (void)groupApplicationDeclined:(QNIMGroup *)group
                        approver:(NSInteger)approver
                          reason:(NSString *)reason;

/**
 * 群成员被禁言
 **/
- (void)groupMembersMutedGroup:(QNIMGroup *)group
                  members:(NSArray<NSNumber *> *)members
                      duration:(NSInteger)duration;

/**
 * 群成员被解除禁言
 **/
- (void)groupMembersUnMutedGroup:(QNIMGroup *)group
                         Unmuted:(NSArray<NSNumber *> *)members;

/**
 * 加入新成员
 **/
- (void)groupMemberJoined:(QNIMGroup *)group
                 memberId:(NSInteger)memberId
                  inviter:(NSInteger)inviter;

/**
 * 群成员退出
 **/
- (void)groupMemberLeft:(QNIMGroup *)group
               memberId:(NSInteger)memberId
                reason:(NSString *)reason;

/**
 * 添加了新管理员
 **/
- (void)groupAdminsAddedGroup:(QNIMGroup *)group
                      members:(NSArray<NSNumber *> *)members;

/**
 * 移除了管理员
 **/
- (void)groupAdminsRemovedFromGroup:(QNIMGroup *)group
                            members:(NSArray<NSNumber *> *)members
                             reason:(NSString *)reason;

/**
 * 成为群主
 **/
- (void)groupOwnerAssigned:(QNIMGroup *)group;

/**
 * 群组信息变更
 **/
- (void)groupInfoDidUpdate:(QNIMGroup *)group
            updateInfoType:(QNIMGroupUpdateInfoType)type;

/**
 * 群成员更改群内昵称
 **/
- (void)groupMemberDidChangeNickName:(QNIMGroup *)group
                       memberId:(long long)memberId
                      nickName:(NSString *)nickName;

/**
 * 收到群公告
 **/
- (void)groupAnnouncementUpdate:(QNIMGroup *)group
                   announcement:(QNIMGroupAnnounment *)announcement;

/**
 * 收到共享文件
 **/
- (void)groupSharedFileUploaded:(QNIMGroup *)group
                  sharedFile:(QNIMGroupSharedFile *)sharedFile;

/**
 * 删除了共享文件
 **/
- (void)groupSharedFileDeleted:(QNIMGroup *)group
                    sharedFile:(QNIMGroupSharedFile *)sharedFile;


/**
 * 共享文件更新文件名
 **/
- (void)groupShareFileDidUpdated:(QNIMGroup *)group
                      sharedFile:(QNIMGroupSharedFile *)sharedFile;



@end

