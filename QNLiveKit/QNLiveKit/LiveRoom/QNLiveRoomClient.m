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
- (void)startLive:(NSString *)roomId callBack:(void (^)(QNLiveRoomInfo * roomInfo))callBack {
    NSString *action = [NSString stringWithFormat:@"client/live/room/%@",roomId];
    [QNLiveNetworkUtil putRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        
        QNLiveRoomInfo *model = [QNLiveRoomInfo mj_objectWithKeyValues:responseData];

        if ([self.roomLifeCycleListener respondsToSelector:@selector(onRoomEnter:)]) {
            [self.roomLifeCycleListener onRoomEnter:[self selfUser]];
        }
        
        callBack(model);
        
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}

//加入直播
- (void)joinRoom:(NSString *)roomId callBack:(void (^)(QNLiveRoomInfo * _Nonnull))callBack {
    NSString *action = [NSString stringWithFormat:@"client/live/room/user/%@",roomId];
    [QNLiveNetworkUtil postRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        
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
    NSString *action = [NSString stringWithFormat:@"client//live/room/user/%@",roomId];
    [QNLiveNetworkUtil deleteRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        
        if ([self.roomLifeCycleListener respondsToSelector:@selector(onRoomLeave:)]) {
            [self.roomLifeCycleListener onRoomLeave:[self selfUser]];
        }
        
        callBack();
        } failure:^(NSError * _Nonnull error) {
            callBack();
        }];
}

//停止直播
- (void)closeRoom:(NSString *)roomId callBack:(void (^)(void))callBack {
    NSString *action = [NSString stringWithFormat:@"client//live/room/%@",roomId];
    [QNLiveNetworkUtil deleteRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        
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
    user.user_id = QN_User_id;
    user.nick = QN_User_nickname;
    user.avatar = QN_User_avatar;
    user.im_userid = QN_IM_userId;
    user.im_username = QN_IM_userName;
    return user;
}
@end
