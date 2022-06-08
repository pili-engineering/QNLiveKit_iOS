//
//  QNPKService.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import "QNPKService.h"
#import "QNLiveNetworkUtil.h"
#import "QNLiveUser.h"

@interface QNPKService ()

@property (nonatomic, copy) NSString *roomId;

@end

@implementation QNPKService

- (instancetype)initWithRoomId:(NSString *)roomId {
    if (self = [super init]) {
        self.roomId = roomId;
    }
    return self;
}

- (void)addPKServiceListener:(id<PKServiceListener>)listener {
    self.pkListener = listener;
}

- (void)removePKServiceListener:(id<PKServiceListener>)listener {
    self.pkListener = nil;
}

- (void)startWithReceiverRoomId:(NSString *)receiverRoomId receiverUid:(NSString *)receiverUid extensions:(NSString *)extensions callBack:(void (^)(QNPKSession * _Nonnull))callBack {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"recv_room_id"] = receiverRoomId;
    params[@"recv_user_id"] = receiverUid;
    params[@"init_room_id"] = self.roomId;
    [QNLiveNetworkUtil postRequestWithAction:@"client/relay/start" params:params success:^(NSDictionary * _Nonnull responseData) {
        
        QNPKSession *model = [QNPKSession mj_objectWithKeyValues:responseData];
        model.receiverRoomId = receiverRoomId;
        model.initiatorRoomId = self.roomId;
        model.initiator = self.selfUser;
        
        QNLiveUser *receiver = [QNLiveUser new];
        receiver.user_id = receiverUid;
        model.receiver = receiver;
        
        if ([self.pkListener respondsToSelector:@selector(onStart:)]) {
            [self.pkListener onStart:model];
        }
        callBack(model);
        
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}


//同意跨房申请
- (void)agreePK:(NSString *)relayID callBack:(void (^)(QNPKSession *pkSession))callBack {

    NSString *action = [NSString stringWithFormat:@"client/relay/%@/agree",relayID];
    [QNLiveNetworkUtil postRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        
        QNPKSession *model = [QNPKSession mj_objectWithKeyValues:responseData];
        
        callBack(model);
        
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}

//结束pk
- (void)stop:(void (^)(void))callBack {
    
}

- (QNLiveUser *)selfUser {
    QNLiveUser *user = [QNLiveUser new];
    user.user_id = QN_User_id;
    user.nick = QN_User_nickname;
    user.avatar = QN_User_avatar;
    user.im_userid = QN_IM_userId;
    user.im_username = QN_IM_userName;
    return user;
}

@end
