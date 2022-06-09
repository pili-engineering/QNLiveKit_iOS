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
@property (nonatomic, copy) NSString *liveId;
@property (nonatomic, weak) id <QNRoomLifeCycleListener> roomLifeCycleListener;
@end

@implementation QNLiveRoomClient

- (instancetype)initWithLiveId:(NSString *)liveId {
    if (self = [super init]) {
        self.liveId = liveId;
    }
    return self;
}

- (void)addRoomLifeCycleListener:(id<QNRoomLifeCycleListener>)lifeCycleListener {
    self.roomLifeCycleListener = lifeCycleListener;
}

- (void)removeRoomLifeCycleListener:(id<QNRoomLifeCycleListener>)lifeCycleListener {
    self.roomLifeCycleListener = nil;
}

//开始直播
- (void)startLive:(void (^)(QNLiveRoomInfo * _Nonnull))callBack {
    
    NSString *action = [NSString stringWithFormat:@"client/live/room/%@",self.liveId];
    [QNLiveNetworkUtil putRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        
        QNLiveRoomInfo *model = [QNLiveRoomInfo mj_objectWithKeyValues:responseData];

        if ([self.roomLifeCycleListener respondsToSelector:@selector(onRoomJoined:)]) {
            [self.roomLifeCycleListener onRoomJoined:model];
        }
        
        callBack(model);
        
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}

//加入直播
- (void)joinRoom:(void (^)(QNLiveRoomInfo * _Nonnull))callBack {
    
    NSString *action = [NSString stringWithFormat:@"client/live/room/user/%@",self.liveId];
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
- (void)leaveRoom:(void (^)(void))callBack {
    
    NSString *action = [NSString stringWithFormat:@"client//live/room/user/%@",self.liveId];
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
- (void)closeRoom:(void (^)(void))callBack {
    
    NSString *action = [NSString stringWithFormat:@"client//live/room/%@",self.liveId];
    [QNLiveNetworkUtil deleteRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        
        if ([self.roomLifeCycleListener respondsToSelector:@selector(onRoomClose)]) {
            [self.roomLifeCycleListener onRoomClose];
        }
        
        callBack();
        } failure:^(NSError * _Nonnull error) {
            callBack();
        }];
}

//获取房间详情
- (void)getRoomInfo:(void (^)(QNLiveRoomInfo * _Nonnull))callBack {
    
    NSString *action = [NSString stringWithFormat:@"client/live/room/info/%@",self.liveId];
    [QNLiveNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        QNLiveRoomInfo *model = [QNLiveRoomInfo mj_objectWithKeyValues:responseData];
        callBack(model);
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}

//获取房间所有用户
- (void)getUserListWithPageNumber:(NSInteger)pageNumber pageSize:(NSInteger)pageSize callBack:(void (^)(NSArray<QNLiveUser *> * _Nonnull))callBack {
    
    NSString *action = [NSString stringWithFormat:@"client/live/room/user_list?live_id=%@&page_num=%ld&page_size=%ld",self.liveId,pageNumber,pageSize];
    [QNLiveNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        NSArray <QNLiveUser *> *list = [QNLiveUser mj_objectArrayWithKeyValuesArray:responseData[@"list"]];
        callBack(list);
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}

//房间心跳
- (void)roomHeartBeart {
    
    __weak typeof(self) weakSelf = self;

    NSString *action = [NSString stringWithFormat:@"client/live/room/heartbeat/%@",self.liveId];
    [QNLiveNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        
        } failure:^(NSError * _Nonnull error) {
            
        }];
}

//更新直播扩展信息
- (void)updateRoomExtension:(NSString *)extension callBack:(void (^)(void))callBack{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"live_id"] = self.liveId;
    params[@"extends"] = extension;

    [QNLiveNetworkUtil putRequestWithAction:@"client/live/room/extends" params:params success:^(NSDictionary * _Nonnull responseData) {        
        
        if ([self.roomLifeCycleListener respondsToSelector:@selector(onRoomExtensions:)]) {
            [self.roomLifeCycleListener onRoomExtensions:extension];
        }
        callBack();
        
        } failure:^(NSError * _Nonnull error) {
            callBack();
        }];
}

//某个房间在线用户
- (void)getOnlineUser:(NSString *)roomId callBack:(void (^)(NSArray <QNLiveUser *> *list))callBack{
    NSString *action = [NSString stringWithFormat:@"client/live/room/user_list?live_id=%@&page_num=1&page_size=20",roomId];
    [QNLiveNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        NSArray <QNLiveUser *> *list = [QNLiveUser mj_objectArrayWithKeyValuesArray:responseData[@"list"]];
        callBack(list);
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}

//获取自己的信息
- (void)getSelfUser:(void (^)(QNLiveUser * _Nonnull))callBack {
    
    [QNLiveNetworkUtil getRequestWithAction:@"client/user/profile" params:nil success:^(NSDictionary * _Nonnull responseData) {
        QNLiveUser *user = [QNLiveUser mj_objectWithKeyValues:responseData];
        callBack(user);
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}

//使用用户ID搜索用户
- (void)searchUserByUserId:(NSString *)uid callBack:(void (^)(QNLiveUser *user))callBack{
    
    NSString *action = [NSString stringWithFormat:@"client/user/%@",uid];
    [QNLiveNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        QNLiveUser *user = [QNLiveUser mj_objectWithKeyValues:responseData];
        callBack(user);
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}

//使用用户im uid 搜索用户
- (void)searchUserByIMUid:(NSString *)imUid callBack:(void (^)(QNLiveUser *user))callBack{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"im_user_ids"] = @[imUid].mj_keyValues;
    [QNLiveNetworkUtil getRequestWithAction:@"client/user/imusers" params:params success:^(NSDictionary * _Nonnull responseData) {
        QNLiveUser *user = [QNLiveUser mj_objectWithKeyValues:responseData];
        callBack(user);
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
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
