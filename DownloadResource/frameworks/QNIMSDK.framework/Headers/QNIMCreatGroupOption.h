//
//  QNIMCreatGroupOption.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>
#import "QNIMGroup.h"

@class QNIMGroupMember;

NS_ASSUME_NONNULL_BEGIN

@interface QNIMCreatGroupOption : NSObject

/**
 群名称
 */
@property (nonatomic,copy) NSString *name;


/**
 群描述
 */
@property (nonatomic,copy) NSString *groupDescription;

/**
 是否聊天室
 */
@property (nonatomic, assign) BOOL isChatroom;

/**
 建群时成员收到的邀请信息
 */
@property (nonatomic,copy) NSString *message;


/**
 群头像本地路径
 */
@property (nonatomic,copy) NSString *avatarPath;

/**
 群公告
 */
@property (nonatomic,copy) NSString *announcement;

/**
 建群时添加的成员
 */
@property (nonatomic,strong) NSArray *members;


/**
 群扩展信息
 */
@property (nonatomic,copy) NSString *extension;


/**
 创建群实体

 @param name 必填
 @param groupDescription 非必填
 @return QNIMCreatGroupOption
 */
- (instancetype)initWithGroupName:(NSString *)name
                 groupDescription:(NSString *)groupDescription
                         isPublic:(BOOL)isPublic;


@end

NS_ASSUME_NONNULL_END
