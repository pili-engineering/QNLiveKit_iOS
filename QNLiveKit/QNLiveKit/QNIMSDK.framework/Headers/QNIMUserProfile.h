//
//  QNIMUserProfile.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/6/1.
//

#import <Foundation/Foundation.h>
@class QNIMAuthQuestion;
@class QNIMMessageSetting;


typedef enum {
    QNIMQNIMOpen = 0,           // 无需验证，任何人可以加为好友
    QNIMQNIMNeedApproval,   // 需要同意方可加为好友
    QNIMQNIMAnswerQuestion, // 需要回答问题正确方可加为好友
    QNIMQNIMRejectAll       // 拒绝所有加好友申请
} QNIMAddFriendAuthMode;

typedef enum {
    QNIMUserCategoryNormal = 0, // 普通用户
    QNIMUserCategoryAdvanced,  // 高级用户
} QNIMUserCategory;

@interface QNIMUserProfile : NSObject


/**
 用户id
 */
@property (nonatomic,assign) long long userId;

/**
 用户级别
 */
@property (nonatomic,assign) QNIMUserCategory userCategory;

/**
 用户名
 */
@property (nonatomic,copy) NSString *userName;

/**
 昵称
 */
@property (nonatomic,copy) NSString *nickName;

/**
 头像url
 */
@property (nonatomic,copy) NSString *avatarUrl;

/**
 头像本地路径
 */
@property (nonatomic,copy) NSString *avatarPath;

/**
 头像缩略图url
 */
@property (nonatomic,copy) NSString *avatarThumbnailUrl;

/**
 头像缩略图本地路径
 */
@property (nonatomic,copy) NSString *avatarThumbnailPath;

/**
 手机号
 */
@property (nonatomic,copy) NSString *mobilePhone;

/**
  用户邮箱
 */
@property (nonatomic,copy) NSString *email;

/**
 公开信息
 */
@property (nonatomic,copy) NSString *publicInfoJson;

/**
 私密信息
 */
@property (nonatomic,copy) NSString *privateInfoJson;

/**
 验证问题
 */
@property (nonatomic, strong) QNIMAuthQuestion *authQuestion;

/**
 消息设置
 */
@property (nonatomic, strong) QNIMMessageSetting *messageSetting;

/**
 好友验证模式
 */
@property (nonatomic, assign) QNIMAddFriendAuthMode addFriendAuthMode;

/**
 自动接收群邀请
 */
@property (nonatomic,assign) BOOL isAutoAcceptGroupInvite;

@end
