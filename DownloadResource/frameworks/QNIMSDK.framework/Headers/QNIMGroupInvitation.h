//
//  QNIMGroupInvitation.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    QNIMGroupInvitationStatusPending,
    QNIMGroupInvitationStatusAccepted,
    QNIMGroupInvitationStatusDeclined,
} QNIMGroupInvitationStatus;

NS_ASSUME_NONNULL_BEGIN

@interface QNIMGroupInvitation : NSObject

@property (nonatomic,assign, readonly) long long groupId;
@property (nonatomic,assign, readonly) long long inviterId;
@property (nonatomic,assign, readonly) long long expiredTime;
@property (nonatomic,copy, readonly) NSString *reason;
@property (nonatomic,assign, readonly) QNIMGroupInvitationStatus invitationStatus;

@end

NS_ASSUME_NONNULL_END
