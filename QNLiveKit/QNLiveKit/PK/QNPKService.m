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

- (void)startWithReceiverRoomId:(NSString *)receiverRoomId receiverUid:(NSString *)receiverUid extensions:(NSString *)extensions callBack:(nullable void (^)(QNPKSession * _Nullable))callBack {
    
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
        
//        if ([self.pkListener respondsToSelector:@selector(onStart:)]) {
//            [self.pkListener onStart:model];
//        }
        callBack(model);
        
        } failure:^(NSError * _Nonnull error) {

        }];
}

- (void)getPKToken:(NSString *)relayID callBack:(nullable void (^)(QNPKSession * _Nullable))callBack {
    NSString *action = [NSString stringWithFormat:@"client/relay/%@/token",relayID];
    [QNLiveNetworkUtil getRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        
        QNPKSession *model = [QNPKSession mj_objectWithKeyValues:responseData];
        callBack(model);
        
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}

- (void)PKStartedWithRelayID:(NSString *)relayID {
    NSString *action = [NSString stringWithFormat:@"client/relay/%@/started",relayID];
    [QNLiveNetworkUtil postRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {        
        } failure:^(NSError * _Nonnull error) {
        }];
}

//结束pk
- (void)stopWithRelayID:(NSString *)relayID callBack:(nullable void (^)(void))callBack {
    NSString *action = [NSString stringWithFormat:@"client/relay/%@/stop",relayID];
    [QNLiveNetworkUtil postRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        callBack();
        } failure:^(NSError * _Nonnull error) {
            callBack();
        }];
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
