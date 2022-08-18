//
//  QNIMGroup.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/6/7.
//

#import <Foundation/Foundation.h>

@class QNIMGroupSharedFile;
@class QNIMGroupMember;
@class QNIMGroupAnnounment;

/**
 * 消息通知类型
 **/
typedef enum {
    QNIMGroupMsgPushModeAll = 0,       // 通知所有群消息
    QNIMGroupMsgPushModeNone,      // 所有消息都不通知
    QNIMGroupMsgPushModeAdminOrAt, // 只通知管理员或者被@消息
    QNIMGroupMsgPushModeAdmin,     // 只通知知管理员消息
    QNIMGroupMsgPushModeAt         // 只通知被@消息
} QNIMGroupMsgPushMode;

/**
 * 群信息修改模式
 **/
typedef enum {
    QNIMGroupModifyModeAdminOnly = 0,
    QNIMGroupModifyModeOpen,
} QNIMGroupModifyMode;


/**
 * 进群验证方式
 **/
typedef enum  {
    QNIMGroupJoinAuthOpen = 0,
    QNIMGroupJoinAuthNeedApproval,
    QNIMGroupJoinAuthRejectAll,
} QNIMGroupJoinAuthMode;

/**
 * 邀请入群模式
 **/
typedef enum {
    QNIMGroupInviteModeAdminOnly = 0,// 只有管理员可以
    QNIMGroupInviteModeOpen, // 所有群成员都可以修改

} QNIMGroupInviteMode;


typedef enum {
    QNIMGroupUpdateInfoTypeUnKnown = 0,        // 默认初始化值
    QNIMGroupUpdateInfoTypeName,           // 修改群名称
    QNIMGroupUpdateInfoTypeDescription,    // 修改群描述
    QNIMGroupUpdateInfoTypeAvatar,         // 修改群头像
    QNIMGroupUpdateInfoTypeOwner,          // 修改群主
    QNIMGroupUpdateInfoTypeExt,            // 修改群扩展
    QNIMGroupUpdateInfoTypeNickName,       // 群成员修改群名片
    QNIMGroupUpdateInfoTypeModifyMode,     // 修改群信息模式
    QNIMGroupUpdateInfoTypeJoinAuthMode,   // 修改进群验证方式
    QNIMGroupUpdateInfoTypeInviteMode,     // 修改邀请入群模式
    QNIMGroupUpdateInfoTypeMsgPushMode,          // 修改群消息推送类型
    QNIMGroupUpdateInfoTypeMsgMuteMode,          // 修改是否提醒消息
    QNIMGroupUpdateInfoTypeReadAckMode,          // 是否开启群消息已读功能
    QNIMGroupUpdateInfoTypeHistoryVisibleMode,   // 新群成员是否可见群历史聊天记录
    
} QNIMGroupUpdateInfoType;

/**
 * 群组状态
 **/
typedef enum {
    QNIMGroupNormal,         // 群组状态正常
    QNIMGroupDestroyed,      // 群组已销毁
} QNIMGroupStatus;


typedef enum  {
    QNIMGroupMsgMuteModeNone, // 不屏蔽
    QNIMGroupMsgMuteModeMuteNotification, // 屏蔽本地消息通知
    QNIMGroupMsgMuteModeMuteChat, // 屏蔽消息，不接收消息
} QNIMGroupMsgMuteMode;

typedef enum {
    /// 群成员
    QNIMGroupMemberRoleTypeMember,
    /// 群管理员
    QNIMGroupMemberRoleTypeAdmin,
    /// 群主
    QNIMGroupMemberRoleTypeOwner,
    /// 非群成员
    QNIMGroupMemberRoleTypeNotGroupMember
} QNIMGroupMemberRoleType;

typedef enum {
    /// 私有群组
    QNIMGroupTypePrivate,
    /// 公开群组(现在暂时没有开放次类型群组)
    QNIMGroupTypePublic,
    /// 聊天室
    QNIMGroupTypeChatroom,
} QNIMGroupType;

NS_ASSUME_NONNULL_BEGIN

@interface QNIMGroup : NSObject
/**
 * 群Id
 **/
@property (nonatomic,assign) long long groupId;


@property (nonatomic, assign) QNIMGroupType groupType;

/**
 * 在群里的昵称
 **/
@property (nonatomic,copy) NSString *myNickName;

/**
 * 群名称
 **/
@property (nonatomic, copy) NSString *name;

/**
 * 群描述
 **/
@property (nonatomic, copy) NSString *groupDescription;

/**
 * 群头像
 **/
@property (nonatomic,copy) NSString *avatarUrl;

/**
 * 群头像下载后的本地路径
 **/
@property (nonatomic,copy) NSString *avatarPath;

/**
 * 群头像缩略图
 **/
@property (nonatomic,copy) NSString *avatarThumbnailUrl;

/**
 * 群头像缩略图下载后的本地路径
 **/
@property (nonatomic,copy ) NSString *avatarThumbnailPath;

/**
 * 群创建时间
 **/
@property (nonatomic) long long creatTime;

/**
 * 群扩展信息
 **/
@property (nonatomic, copy ) NSString *jsonextension;


//@property (nonatomic, strong ) QNIMGroupSharedFile *shareFile;

/**
 * 群成员
 **/
@property (nonatomic, assign ) NSInteger ownerId;


@property (nonatomic, strong) QNIMGroupAnnounment *annountment;

/**
 * 最大人数
 **/
@property (nonatomic, assign ) NSInteger capactiy;

/**
 * 群成员数量，包含Owner，admins 和members
 **/
@property (nonatomic, assign ) NSInteger membersCount;

/**
 * 群管理员数量
 **/
@property (nonatomic, assign ) NSInteger adminsCount;

/**
 * 群共享文件数量
 **/
@property (nonatomic, assign ) NSInteger sharedFilesCount;

/**
 群消息通知类型
 */
@property (nonatomic,assign ) QNIMGroupMsgPushMode msgPushMode;

/**
 群信息修改模式
 */
@property (nonatomic,assign ) QNIMGroupModifyMode modifyMode;

/**
 入群审批模式
 */
@property (nonatomic,assign ) QNIMGroupJoinAuthMode joinAuthMode;

/**
 入群邀请模式
 */
@property (nonatomic,assign ) QNIMGroupInviteMode inviteMode;

/**
 是否开启群消息已读功能
 */
@property (nonatomic,assign) BOOL enableReadAck;

/**
 是否可以加载显示历史聊天记录
 */
@property (nonatomic,assign) BOOL historyVisible;


/**
 * 群消息屏蔽模式
 **/
@property (nonatomic, assign) QNIMGroupMsgMuteMode msgMuteMode;

/**
 * 当前群组的状态。（Normal 正常， Destroyed 以销毁）
 **/
@property (nonatomic,assign) QNIMGroupStatus groupStatus;

@property (nonatomic,assign) BOOL isMember;

@property (nonatomic,assign) QNIMGroupMemberRoleType roleType;

@end

NS_ASSUME_NONNULL_END
