//
//  QLinkMicService.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import "QLinkMicService.h"
#import "QLiveNetworkUtil.h"
#import "QNMicLinker.h"
#import "QLive.h"
#import "QNLivePushClient.h"
#import "CreateSignalHandler.h"
#import <QNIMSDK/QNIMSDK.h>
#import "QNLiveRoomInfo.h"
#import "CreateSignalHandler.h"
#import "QNLivePushClient.h"

@interface QLinkMicService ()

@property (nonatomic,strong)CreateSignalHandler *creater;

@end

@implementation QLinkMicService

//获取当前房间所有连麦用户
- (void)getAllLinker:(void (^)(NSArray <QNMicLinker *> *list))callBack {
    
    NSString *action = [NSString stringWithFormat:@"client/mic/room/list/%@",self.roomInfo.live_id];
    
    [QLiveNetworkUtil getRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        
        NSArray <QNMicLinker *> *list = [QNMicLinker mj_objectArrayWithKeyValuesArray:responseData];
        callBack(list);
        
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}

//上麦
- (void)onMic:(BOOL)mic camera:(BOOL)camera extends:(nullable NSDictionary *)extends {
    
    [[QLive createPusherClient] enableCamera:nil renderView:nil];
    
    [self sendOnMicMsg];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"live_id"] = self.roomInfo.live_id;
    params[@"mic"] = @(mic);
    params[@"camera"] = @(camera);
    params[@"extends"] = extends;
    
    [QLiveNetworkUtil postRequestWithAction:@"client/mic/" params:params success:^(NSDictionary * _Nonnull responseData) {
        
        QNMicLinker *mic = [QNMicLinker new];
        mic.user = self.user;
        mic.camera = YES;
        mic.mic = YES;
        mic.userRoomId = self.roomInfo.live_id;
        
        [[QLive createPusherClient].rtcClient join:responseData[@"rtc_token"] userData:mic.mj_JSONString];
        } failure:^(NSError * _Nonnull error) {
        }];
}

//下麦
- (void)downMic{
    
    [[QLive createPusherClient].rtcClient leave];
    [self sendDownMicMsg];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"live_id"] = self.roomInfo.live_id;
    params[@"mic"] = @(NO);
    params[@"camera"] = @(NO);

    [QLiveNetworkUtil deleteRequestWithAction:@"client/mic" params:params success:^(NSDictionary * _Nonnull responseData) {
        
        } failure:^(NSError * _Nonnull error) {
        }];
    
}

//获取用户麦位状态
- (void)getMicStatus:(NSString *)uid type:(NSString *)type callBack:(nullable void (^)(void))callBack{
    
}

//开关麦 type:mic/camera  flag:on/off
- (void)updateMicStatusType:(NSString *)type flag:(BOOL)flag {
    
    if ([type isEqualToString:@"mic"]) {
        [[QLive createPusherClient] muteMicrophone:!flag];
        [self sendMicrophoneMute:!flag];
    } else {
        [[QLive createPusherClient] muteCamera:!flag];
        [self sendCameraMute:!flag];
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"live_id"] = self.roomInfo.live_id;
    params[@"user_id"] = QN_User_id;
    params[@"type"] = type;
    params[@"flag"] = @(flag);

    [QLiveNetworkUtil putRequestWithAction:@"client/mic/switch" params:params success:^(NSDictionary * _Nonnull responseData) {
        } failure:^(NSError * _Nonnull error) {
        }];
}

//踢人
- (void)kickOutUser:(NSString *)uid msg:(nullable NSString *)msg callBack:(nullable void (^)(QNMicLinker * _Nullable))callBack {

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"live_id"] = self.roomInfo.live_id;
    params[@"user_id"] = uid;
    
    [QLiveNetworkUtil deleteRequestWithAction:@"mic/live" params:params success:^(NSDictionary * _Nonnull responseData) {
        
        QNLiveUser *user = [QNLiveUser new];
        user.user_id = uid;
        
        QNMicLinker *mic = [QNMicLinker new];
        mic.user = user;
        mic.userRoomId = self.roomInfo.live_id;
        
        callBack(mic);
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}

//更新扩展字段
- (void)updateExtension:(NSString *)extension callBack:(nullable void (^)(QNMicLinker *mic))callBack {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"live_id"] = self.roomInfo.live_id;
    params[@"user_id"] = QN_User_id;
    params[@"extends"] = extension;

    [QLiveNetworkUtil putRequestWithAction:@"client/mic/extension" params:params success:^(NSDictionary * _Nonnull responseData) {
        
        QNMicLinker *mic = [QNMicLinker mj_objectWithKeyValues:responseData];
        
//        if ([self.micLinkerListener respondsToSelector:@selector(onUserExtension:extension:)]) {
//            [self.micLinkerListener onUserExtension:mic extension:extension];
//        }
        callBack(mic);
        
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}

//发送上麦信令
- (void)sendOnMicMsg {
    QNIMMessageObject *message = [self.creater  createOnMicMessage];
    [[QNIMChatService sharedOption] sendMessage:message];
}

//发送下麦信令
- (void)sendDownMicMsg {
    QNIMMessageObject *message = [self.creater  createDownMicMessage];
    [[QNIMChatService sharedOption] sendMessage:message];
}

- (void)sendMicrophoneMute:(BOOL)mute {
    QNIMMessageObject *message = [self.creater  createMicStatusMessage:!mute];
    [[QNIMChatService sharedOption] sendMessage:message];
    
}
- (void)sendCameraMute:(BOOL)mute {
    QNIMMessageObject *message = [self.creater  createCameraStatusMessage:!mute];
    [[QNIMChatService sharedOption] sendMessage:message];
}

- (QNLiveUser *)user {
    
    QNLiveUser *user = [QNLiveUser new];
    user.user_id = QN_User_id;
    user.nick = QN_User_nickname;
    user.avatar = QN_User_avatar;
    user.im_userid = QN_IM_userId;
    user.im_username = QN_IM_userName;
    return user;
}

- (CreateSignalHandler *)creater {
    if (!_creater) {
        _creater = [[CreateSignalHandler alloc]initWithToId:self.roomInfo.chat_id roomId:self.roomInfo.live_id];
    }
    return _creater;
}

@end
