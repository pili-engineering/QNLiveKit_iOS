//
//  QGiftMsgModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/25.
//  礼物消息model

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QGiftModel : NSObject

@property(nonatomic, copy) NSString *giftName;

@property(nonatomic, copy) NSString *giftId;

@property(nonatomic, copy) NSString *giftUrl;

@end

@interface QGiftMsgModel : NSObject

@property(nonatomic, copy) NSString *senderName;

@property(nonatomic, copy) NSString *senderUid;

@property(nonatomic, copy) NSString *senderRoomId;

@property(nonatomic, copy) NSString *senderAvatar;
//扩展消息
@property(nonatomic, copy) NSString *extMsg;
//送出个数
@property(nonatomic, assign) NSInteger number;
//礼物
@property(nonatomic, strong) QGiftModel *sendGift;

@end

NS_ASSUME_NONNULL_END
