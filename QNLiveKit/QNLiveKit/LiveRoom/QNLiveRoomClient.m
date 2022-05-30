//
//  QNLiveRoomClient.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import "QNLiveRoomClient.h"
#import "QNLiveNetworkUtil.h"
#import "QNLiveUser.h"
#import "QNLiveRoomInfo.h"

@interface QNLiveRoomClient ()<QNRoomLifeCycleListener>
@property (nonatomic, weak) id <QNRoomLifeCycleListener> roomLifeCycleListener;
@end

@implementation QNLiveRoomClient

- (void)addRoomLifeCycleListener:(id<QNRoomLifeCycleListener>)lifeCycleListener {
    self.roomLifeCycleListener = lifeCycleListener;
}

- (void)removeRoomLifeCycleListener:(id<QNRoomLifeCycleListener>)lifeCycleListener {
    self.roomLifeCycleListener = nil;
}

//开始直播
- (void)startLive:(NSString *)roomId callBack:(nonnull void (^)(void))callBack {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"live_id"] = roomId;
    [QNLiveNetworkUtil putRequestWithAction:@"live/room" params:param success:^(NSDictionary * _Nonnull responseData) {
        
        if ([self.roomLifeCycleListener respondsToSelector:@selector(onRoomEnter:)]) {
            [self.roomLifeCycleListener onRoomEnter:[self selfUser]];
        }
        callBack();
        
        } failure:^(NSError * _Nonnull error) {
            callBack();
        }];
}

//加入直播
- (void)joinRoom:(NSString *)roomId callBack:(void (^)(QNLiveRoomInfo * _Nonnull))callBack {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"live_id"] = roomId;
    [QNLiveNetworkUtil postRequestWithAction:@"/live/room/user" params:param success:^(NSDictionary * _Nonnull responseData) {
        
        QNLiveRoomInfo *model = [QNLiveRoomInfo mj_objectWithKeyValues:responseData];
        
        if ([self.roomLifeCycleListener respondsToSelector:@selector(onRoomJoined:)]) {
            [self.roomLifeCycleListener onRoomJoined:model];
        }
        callBack(model);
        
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}

//离开直播
- (void)leaveRoom:(NSString *)roomId callBack:(void (^)(void))callBack{
    NSString *action = [NSString stringWithFormat:@"/live/room/user?live_id=%@",roomId];
    [QNLiveNetworkUtil deleteRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        
        if ([self.roomLifeCycleListener respondsToSelector:@selector(onRoomLeave:)]) {
            [self.roomLifeCycleListener onRoomLeave:[self selfUser]];
        }
        
        callBack();
        } failure:^(NSError * _Nonnull error) {
            callBack();
        }];
}

//关闭直播
- (void)closeRoom:(NSString *)roomId callBack:(void (^)(void))callBack {
    NSString *action = [NSString stringWithFormat:@"/live/room?live_id=%@",roomId];
    [QNLiveNetworkUtil deleteRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        
        if ([self.roomLifeCycleListener respondsToSelector:@selector(onRoomClose)]) {
            [self.roomLifeCycleListener onRoomClose];
        }
        
        callBack();
        } failure:^(NSError * _Nonnull error) {
            callBack();
        }];
}

- (QNLiveUser *)selfUser {
    QNLiveUser *user = [QNLiveUser new];
    user.anchor_id = QN_User_id;
    user.nickname = QN_User_nickname;
    user.avatar = QN_User_avatar;
    user.qnImUid = QN_IM_userId;
    return user;
}
@end
