//
//  QNInvitationModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/8.
//  邀请消息model

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LinkInvitation;

@interface QInvitationInfo : NSObject

@property(nonatomic, copy) NSString *channelId;

@property(nonatomic, copy) NSString *flag;

@property(nonatomic, copy) NSString *initiatorUid;

//@property(nonatomic, strong) LinkInvitation *msg;
@property (nonatomic, copy) NSString *msg;

@property (nonatomic, copy) NSString *receiver;

@property (nonatomic, copy) NSString *timeStamp;

@property (nonatomic, strong) LinkInvitation *linkInvitation;
@end

@interface QInvitationModel : NSObject

@property(nonatomic, strong) QInvitationInfo *invitation;

@property(nonatomic, copy) NSString *invitationName;

@property (nonatomic, copy) NSDictionary *extends;

@end


@interface QExtension : NSObject
//跨房会话ID
@property (nonatomic, copy)NSString *key;
//跨房token
@property (nonatomic, copy)NSString *value;

@end

NS_ASSUME_NONNULL_END
