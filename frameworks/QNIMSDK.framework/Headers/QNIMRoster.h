//
//  QNIMRoster.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>

typedef enum {
    QNIMRosterRelationFriend,       // 好友
    QNIMRosterRelationDeleted,      // 被删除
    QNIMRosterRelationStranger,     // 陌生人
    QNIMRosterRelationonBlockd,    // 被加入黑名单
} QNIMRosterRelation;

NS_ASSUME_NONNULL_BEGIN

@interface QNIMRoster : NSObject

/**
 好友Id
 */
@property (nonatomic,assign) long long rosterId;

/**
 好友名
 */
@property (nonatomic,copy) NSString *userName;

/**
 好友昵称
 */
@property (nonatomic,copy) NSString *nickName;

/**
 好友头像
 */
@property (nonatomic,copy) NSString *avatarUrl;

/**
 好友头像本地存储路径
 */
@property (nonatomic,copy) NSString *avatarPath;

/**
 好友头像缩略图本地存储路径
 */
@property (nonatomic,copy) NSString *avatarThumbnailPath;


/**
  扩展信息，用户设置的好友可以看到的信息，比如地址，个性签名等
 */
@property (nonatomic,copy) NSString *json_PublicInfo;

/**
 用户对好友添加的备注等信息
 */
@property (nonatomic, copy) NSString *json_alias;

/**
 用户的服务器扩展信息
 */
@property (nonatomic,copy) NSString *json_ext;

/**
 用户的本地扩展信息
 */
@property (nonatomic,copy) NSString *json_localExt;

/**
 是否提醒用户消息
 */
@property (nonatomic, assign) BOOL isMuteNotification;

/**
 联系人关系
 */
@property (nonatomic,assign) QNIMRosterRelation rosterRelation;

@end

NS_ASSUME_NONNULL_END
