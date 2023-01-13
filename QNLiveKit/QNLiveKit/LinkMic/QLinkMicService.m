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
#import "QIMModel.h"
#import "LinkOptionModel.h"
#import "QInvitationModel.h"
#import "QNLiveUser.h"

@interface QLinkMicService ()

@property (nonatomic,strong)CreateSignalHandler *creater;



@end

@implementation QLinkMicService

- (instancetype)initWithRoomInfo:(QNLiveRoomInfo *)roomInfo {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveIMMessageNotification:) name:ReceiveIMMessageNotification object:nil];
        self.roomInfo = roomInfo;
        _linkMicList = [[NSMutableArray alloc] init];
        [self getAllLinker:^(NSArray<QNMicLinker *> * _Nonnull list) {
            [_linkMicList addObjectsFromArray:list];
            QLIVELogInfo(@"micLink getAllLinker (%d)",(int)list.count);
        }];
        
    }
    return self;
}

- (void)receiveIMMessageNotification:(NSNotification *)notice {
 
    QLIVELogInfo(@"IMMessage:\n %@",notice.userInfo);
    NSDictionary *dic = notice.userInfo;
    QIMModel *imModel = [QIMModel mj_objectWithKeyValues:dic.mj_keyValues];
    
    if ([imModel.action isEqualToString:liveroom_miclinker_join]) {
        //上麦消息
        QNMicLinker *model = [QNMicLinker mj_objectWithKeyValues:imModel.data];
        
        BOOL isHave = NO;
        for (QNMicLinker *linker in self.linkMicList) {
            if ([linker.user.user_id isEqual:model.user.user_id]) {
                isHave = YES;
            }
        }
        if (!isHave) {
            [self.linkMicList addObject:model];
        }
       
        if ([self.micLinkerListener respondsToSelector:@selector(onUserJoinLink:)]) {
            [self.micLinkerListener onUserJoinLink:model];
        }
        QLIVELogInfo(@"micLink join userID(%@)",model.user.user_id);
    } else if ([imModel.action isEqualToString:liveroom_miclinker_left]) {
        //下麦消息,json 未统一
        
        QNMicLinker2 *model0 = [QNMicLinker2 mj_objectWithKeyValues:imModel.data];
        
        QNMicLinker *model = [[QNMicLinker alloc] init];
        model.user = [[QNLiveUser alloc] init];
        model.user.user_id = model0.uid;
        
        for (QNMicLinker *linker in self.linkMicList) {
            if ([linker.user.user_id isEqual:model.user.user_id]) {
                [self.linkMicList removeObject:linker];
                break;
            }
        }
        
        if ([self.micLinkerListener respondsToSelector:@selector(onUserLeaveLink:)]) {
            [self.micLinkerListener onUserLeaveLink:model];
        }
        QLIVELogInfo(@"micLink leave userID(%@)",model.user.user_id);

    } else if ([imModel.action isEqualToString:liveroom_miclinker_microphone_mute]) {
        //开关音频消息
        LinkOptionModel *model = [LinkOptionModel mj_objectWithKeyValues:imModel.data];
        
        for (QNMicLinker *linker in self.linkMicList) {
            if ([linker.user.user_id isEqual:model.uid]) {
                linker.mic = !model.mute;
                break;
            }
        }
        
        if ([self.micLinkerListener respondsToSelector:@selector(onUserMicrophoneStatusChange:mute:)]) {
            [self.micLinkerListener onUserMicrophoneStatusChange:model.uid mute:model.mute];
        }
        QLIVELogInfo(@"micLink mic mut(%d) userID(%@)",model.mute,model.uid);
    } else if ([imModel.action isEqualToString:liveroom_miclinker_camera_mute]) {
        //开关视频消息
        LinkOptionModel *model = [LinkOptionModel mj_objectWithKeyValues:imModel.data];
        
        if ([self.micLinkerListener respondsToSelector:@selector(onUserCameraStatusChange:mute:)]) {
            [self.micLinkerListener onUserCameraStatusChange:model.uid mute:model.mute];
        }
        QLIVELogInfo(@"micLink camera mut(%d) userID(%@)",model.mute,model.uid);
    } else if ([imModel.action isEqualToString:liveroom_miclinker_kick]) {
        //被踢消息
        LinkOptionModel *model = [LinkOptionModel mj_objectWithKeyValues:imModel.data];
        
        //如果被踢的是自己 发送群消息被踢了
        if ([model.uid isEqualToString:LIVE_User_id]) {
            [self beKickAndDownMic];
            QNIMMessageObject *message = [self.creater createKickMessage:model.uid msg:model.msg];
            [[QNIMChatService sharedOption] sendMessage:message];
        }
        
        for (QNMicLinker *linker in self.linkMicList) {
            if ([linker.user.user_id isEqual:model.uid]) {
                [self.linkMicList removeObject:linker];
                break;
            }
        }
        
        if ([self.micLinkerListener respondsToSelector:@selector(onUserBeKick:)]) {
            [self.micLinkerListener onUserBeKick:model];
        }
        QLIVELogInfo(@"micLink kick userID(%@)",model.uid);
    } else if ([imModel.action isEqualToString:invite_send]) {
        //连麦邀请消息
        QInvitationModel *model = [QInvitationModel mj_objectWithKeyValues:imModel.data];
        if ([model.invitation.linkInvitation.receiver.user_id isEqualToString:LIVE_User_id]) {
            if ([model.invitationName isEqualToString:liveroom_linkmic_invitation]) {
                if ([self.micLinkerListener respondsToSelector:@selector(onReceiveLinkInvitation:)]) {
                    [self.micLinkerListener onReceiveLinkInvitation:model];
                }
            }
        }
        QLIVELogInfo(@"micLink invite_send invitationName(%@)",model.invitationName);
    }  else if ([imModel.action isEqualToString:invite_accept]) {
        //连麦邀请被接受
        QInvitationModel *model = [QInvitationModel mj_objectWithKeyValues:imModel.data];
        if ([model.invitationName isEqualToString:liveroom_linkmic_invitation]) {
            if ([self.micLinkerListener respondsToSelector:@selector(onReceiveLinkInvitationAccept:)]) {
                [self.micLinkerListener onReceiveLinkInvitationAccept:model];
            }
        }
        QLIVELogInfo(@"micLink invite_accept invitationName(%@)",model.invitationName);
    }  else if ([imModel.action isEqualToString:invite_reject]) {
        //连麦邀请被拒绝
        QInvitationModel *model = [QInvitationModel mj_objectWithKeyValues:imModel.data];
        if ([model.invitationName isEqualToString:liveroom_linkmic_invitation]) {
            if ([self.micLinkerListener respondsToSelector:@selector(onReceiveLinkInvitationReject:)]) {
                [self.micLinkerListener onReceiveLinkInvitationReject:model];
            }
        }
        QLIVELogInfo(@"micLink invite_reject invitationName(%@)",model.invitationName);
    }
}

//发送连麦邀请
- (void)ApplyLink:(QNLiveUser *)receiveUser {
    QLIVELogInfo(@"micLink send ApplyLink");
    QNIMMessageObject *message = [self.creater  createInviteMessageWithInvitationName:liveroom_linkmic_invitation receiveRoomId:self.roomInfo.live_id receiveUser:receiveUser];
    [[QNIMChatService sharedOption] sendMessage:message];
}

//接受连麦
- (void)AcceptLink:(QInvitationModel *)invitationModel{
    QLIVELogInfo(@"micLink send AcceptLink");
    invitationModel.invitationName = liveroom_linkmic_invitation;
    QNIMMessageObject *message = [self.creater createAcceptInviteMessageWithInvitationName:liveroom_linkmic_invitation invitationModel:invitationModel];
    [[QNIMChatService sharedOption] sendMessage:message];
}

//拒绝连麦
- (void)RejectLink:(QInvitationModel *)invitationModel {
    QLIVELogInfo(@"micLink send RejectLink");
    invitationModel.invitationName = liveroom_linkmic_invitation;
    QNIMMessageObject *message = [self.creater createRejectInviteMessageWithInvitationName:liveroom_linkmic_invitation invitationModel:invitationModel];
    [[QNIMChatService sharedOption] sendMessage:message];
}

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

//被踢后下麦（不发下麦消息）
- (void)beKickAndDownMic {
    [[QLive createPusherClient].rtcClient leave];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"live_id"] = self.roomInfo.live_id;
    params[@"mic"] = @(NO);
    params[@"camera"] = @(NO);

    [QLiveNetworkUtil deleteRequestWithAction:@"client/mic" params:params success:^(NSDictionary * _Nonnull responseData) {
        
        } failure:^(NSError * _Nonnull error) {
        }];
}

//下麦
- (void)downMic{
    QLIVELogInfo(@"micLink downMic");
    for (QNMicLinker *linker in self.linkMicList) {
        if ([linker.user.user_id isEqual:LIVE_User_id]) {
            [self.linkMicList removeObject:linker];
            break;
        }
    }
    
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
        for (QNMicLinker *linker in self.linkMicList) {
            if ([linker.user.user_id isEqual:LIVE_User_id]) {
                linker.mic = flag;
                break;
            }
        }
        
    } else {
        [[QLive createPusherClient] muteCamera:!flag];
        [self sendCameraMute:!flag];
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"live_id"] = self.roomInfo.live_id;
    params[@"user_id"] = LIVE_User_id;
    params[@"type"] = type;
    params[@"flag"] = @(flag);

    [QLiveNetworkUtil putRequestWithAction:@"client/mic/switch" params:params success:^(NSDictionary * _Nonnull responseData) {
        } failure:^(NSError * _Nonnull error) {
        }];
}

//踢人
- (void)kickOutUser:(NSString *)uid msg:(nullable NSString *)msg callBack:(nullable void (^)(QNMicLinker * _Nullable))callBack {

    LinkOptionModel *model = [LinkOptionModel new];
    model.uid = uid;
    model.msg = msg;

    QIMModel *messageModel = [QIMModel new];
    messageModel.action = liveroom_miclinker_kick;
    messageModel.data = model.mj_keyValues;
    
    [self getAllLinker:^(NSArray<QNMicLinker *> * _Nonnull list) {
            
        [list enumerateObjectsUsingBlock:^(QNMicLinker * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.user.user_id isEqualToString:uid]) {
                QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:obj.user.im_userid.longLongValue type:QNIMMessageTypeSingle conversationId:obj.user.im_userid.longLongValue];
               
               message.senderName = LIVE_User_nickname;
               [[QNIMChatService sharedOption] sendMessage:message];
            }
        }];
    }];
    
         
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
- (void)updateExtension:(NSString *)extension callBack:(nullable void (^)(void))callBack {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"live_id"] = self.roomInfo.live_id;
    params[@"user_id"] = LIVE_User_id;
    params[@"extends"] = extension;

    [QLiveNetworkUtil putRequestWithAction:@"client/mic/extension" params:params success:^(NSDictionary * _Nonnull responseData) {
        
        callBack();
        
        } failure:^(NSError * _Nonnull error) {
            callBack();
        }];
}

//发送上麦信令
- (void)sendOnMicMsg {
    QNIMMessageObject *message = [self.creater  createOnMicMessage];
    [[QNIMChatService sharedOption] sendMessage:message];
}

//发送下麦信令
- (void)sendDownMicMsg {
    QLIVELogInfo(@"micLink sendDownMicMsg");
    QNIMMessageObject *message = [self.creater  createDownMicMessage];
    [[QNIMChatService sharedOption] sendMessage:message];
}

- (void)sendMicrophoneMute:(BOOL)mute {
    QLIVELogInfo(@"micLink sendMicrophoneMute (%d)",mute);
    QNIMMessageObject *message = [self.creater  createMicStatusMessage:!mute];
    [[QNIMChatService sharedOption] sendMessage:message];
    
}
- (void)sendCameraMute:(BOOL)mute {
    QLIVELogInfo(@"micLink sendCameraMute (%d)",mute);
    QNIMMessageObject *message = [self.creater  createCameraStatusMessage:!mute];
    [[QNIMChatService sharedOption] sendMessage:message];
}

- (BOOL)isMicLinked:(NSString *)userID{
    BOOL isLinked = NO;
    for (QNMicLinker *linker in self.linkMicList) {
        if ([linker.user.user_id isEqual:userID]) {
            isLinked = YES;
        }
    }
    return isLinked;
}


- (QNLiveUser *)user {
    
    QNLiveUser *user = [QNLiveUser new];
    user.user_id = LIVE_User_id;
    user.nick = LIVE_User_nickname;
    user.avatar = LIVE_User_avatar;
    user.im_userid = LIVE_IM_userId;
    user.im_username = LIVE_IM_userName;
    return user;
}

- (CreateSignalHandler *)creater {
    if (!_creater) {
        _creater = [[CreateSignalHandler alloc]initWithToId:self.roomInfo.chat_id roomId:self.roomInfo.live_id];
    }
    return _creater;
}

@end
