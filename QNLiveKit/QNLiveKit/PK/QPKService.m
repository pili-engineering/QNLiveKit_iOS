//
//  QPKService.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import "QPKService.h"
#import "QLiveNetworkUtil.h"
#import "QNLiveUser.h"
#import "CreateSignalHandler.h"
#import "QIMModel.h"
#import "LinkOptionModel.h"
#import "QInvitationModel.h"
#import "QNPKExtendsModel.h"
#import <QNIMSDK/QNIMSDK.h>
#import "QNPKRespModel.h"

#pragma mark - QPKService

@interface QPKService ()

@property (nonatomic, strong) CreateSignalHandler *creater;
@property (nonatomic, strong) QNPKSession *pkSession;
//跨房pkToken（relay_token）
@property (nonatomic, copy) NSString *pkToken;
//PK超时计时器
@property (nonatomic, strong) NSTimer *timeoutTimer;
//PK超时回调
@property (nonatomic, copy) QNPKTimeoutBlock timeoutBlock;

@end

@implementation QPKService

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveIMMessageNotification:) name:ReceiveIMMessageNotification object:nil];
        
        //（如果是观众端）接收观众端进房成功通知后，获取PK房间信息，再通过代理回调
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceivePullClientJoinedRoom:) name:ReceivePullClientJoinedRoom object:nil];
        
    }
    return self;
}

#pragma mark - 接收IM消息通知

/**
 接收IM消息
 */
- (void)receiveIMMessageNotification:(NSNotification *)notice {
    
    NSDictionary *dic = notice.userInfo;
    QLIVELog(@"~~~~~~~~dic: %@", dic);
    
    QIMModel *imModel = [QIMModel mj_objectWithKeyValues:dic.mj_keyValues];
    
    QLIVELog(@"IM (%@)",imModel.action);
    
    if ([imModel.action isEqualToString:invite_send]) {
       //收到pk邀请消息
       QInvitationModel *model = [QInvitationModel mj_objectWithKeyValues:imModel.data];
       if ([model.invitation.linkInvitation.receiver.user_id isEqualToString:LIVE_User_id]) {
           if ([model.invitationName isEqualToString:liveroom_pk_invitation]) {
               if ([self.delegate respondsToSelector:@selector(onReceivePKInvitation:)]) {
                   [self.delegate onReceivePKInvitation:model];
               }
           }
       }
   }  else if ([imModel.action isEqualToString:invite_accept]) {
       //pk邀请被接受
       QInvitationModel *model = [QInvitationModel mj_objectWithKeyValues:imModel.data];

        if ([model.invitationName isEqualToString:liveroom_pk_invitation]) {
            // QInvitationModel ->转 QNPKSession
            QNPKSession *session = [QNPKSession fromInvitationModel:model];
            if ([self.delegate respondsToSelector:@selector(onReceivePKInvitationAccept:)]) {
                [self.delegate onReceivePKInvitationAccept:session];
            }
        }
   }  else if ([imModel.action isEqualToString:invite_reject]) {
       //pk邀请被拒绝
       QInvitationModel *model = [QInvitationModel mj_objectWithKeyValues:imModel.data];
                  
        if ([model.invitationName isEqualToString:liveroom_pk_invitation]) {
            if ([self.delegate respondsToSelector:@selector(onReceivePKInvitationReject:)]) {
                [self.delegate onReceivePKInvitationReject:model];
            }                       
        }
   }  else if ([imModel.action isEqualToString:liveroom_pk_start]) {
       //收到（发起方）PK开始的消息
       QNPKSession *session = [QNPKSession mj_objectWithKeyValues:imModel.data];
       QLIVELogInfo(@"===== 接收到（发起方）开始PK的 c2c消息 =====");
       
       if ([LIVE_User_id isEqualToString:session.initiator.user_id] || [LIVE_User_id isEqualToString:session.receiver.user_id]) { //主播端
           //保存（接受方）pkSession
           self.pkSession = session;
           
           __weak typeof(self) weakSelf = self;
           //获取（接受方）的pkToken
           [self getPKToken:session.sessionId success:^(QNPKRespModel * respModel) {
               //并更新pkSession
               weakSelf.pkSession.sessionId = respModel.sessionId;
               weakSelf.pkSession.status = (QNPKStatus)respModel.status;
               
               //保存（接受方）pkToken
               weakSelf.pkToken = respModel.pkToken;
               
               QLIVELogDebug(@"===== （接受方）开始PK建连: 参数：%@", weakSelf.pkSession.mj_keyValues);
               //（接受方）PK建连
               [weakSelf pkConnect:weakSelf.pkSession success:^{
                   QLIVELogInfo(@"===== （接受方）PK建连 成功！=====");
                   QLIVELogInfo(@"===== （主播端）PK开始：onReceiveStartPKSession =====");
                   if ([weakSelf.delegate respondsToSelector:@selector(onReceiveStartPKSession:)]) {
                       [weakSelf.delegate onReceiveStartPKSession:weakSelf.pkSession];
                   }
               } failure:^(NSError * _Nonnull error) {
                   QLIVELogError(@"===== （接受方）PK建连 失败！ %@", error);
               }];
           } failure:nil];
           
       } else { //观众端
           QLIVELogInfo(@"===== （观众端）收到PK开始：onReceiveStartPKSession =====");
           if ([self.delegate respondsToSelector:@selector(onReceiveStartPKSession:)]) {
               [self.delegate onReceiveStartPKSession:session];
           }
       }
   }  else if ([imModel.action isEqualToString:liveroom_pk_stop]) {
       //结束pk
       QNPKSession *model = [QNPKSession mj_objectWithKeyValues:imModel.data];
                   
       if ([self.delegate respondsToSelector:@selector(onReceiveStopPKSession:)]) {
           [self.delegate onReceiveStopPKSession:model];
       }
   }  else if ([imModel.action isEqualToString:liveroom_pk_extends]) { //pk_extends_notify
       //PK扩展字段
       QNPKExtendsModel *model = [QNPKExtendsModel mj_objectWithKeyValues:imModel.data];
       QLIVELogInfo(@"===== 扩展字段变化回调 onReceivePKExtendsChange =====");
       if ([self.delegate respondsToSelector:@selector(onReceivePKExtendsChange:)]) {
           [self.delegate onReceivePKExtendsChange:model];
       }
   }
}


#pragma mark - 发送IM消息

//发送PK申请
- (void)applyPK:(NSString *)receiveRoomId receiveUser:(nonnull QNLiveUser *)receiveUser {
    QNIMMessageObject *message = [self.creater  createInviteMessageWithInvitationName:liveroom_pk_invitation receiveRoomId:receiveRoomId receiveUser:receiveUser];
    [[QNIMChatService sharedOption] sendMessage:message];
}

//接受PK申请
- (void)acceptPK:(QInvitationModel *)invitationModel {
    invitationModel.invitationName = liveroom_pk_invitation;
    QNIMMessageObject *message = [self.creater  createAcceptInviteMessageWithInvitationName:liveroom_pk_invitation invitationModel:invitationModel];
    [[QNIMChatService sharedOption] sendMessage:message];
}

//拒绝PK申请
- (void)rejectPK:(QInvitationModel *)invitationModel {
    invitationModel.invitationName = liveroom_pk_invitation;
    QNIMMessageObject *message = [self.creater  createRejectInviteMessageWithInvitationName:liveroom_pk_invitation invitationModel:invitationModel];
    [[QNIMChatService sharedOption] sendMessage:message];
}

//发送开始pk信令
- (void)sendStartPKMessage:(QNPKSession *)pkSession singleMsg:(BOOL)singleMsg {
    QLIVELogInfo(@"===== (发起方）发送c2c消息: sendStartPKMessage =====");
    QNIMMessageObject *message = [self.creater createStartPKMessage:pkSession singleMsg:singleMsg];
    [[QNIMChatService sharedOption] sendMessage:message];
}

//发送结束pk信令
- (void)createStopPKMessage:(QNPKSession *)pkSession  {
    QNIMMessageObject *message = [self.creater createStopPKMessage:pkSession];
    [[QNIMChatService sharedOption] sendMessage:message];
}


#pragma mark - （发起方）PK操作

/**
 开始PK
 */
- (void)startPK:(QNPKSession *)pkSession timeoutInterval:(double)timeoutInterval success:(nullable QNPKSuccessBlock)success failure:(nullable QNPKFailureBlock)failure timeout:(nullable QNPKTimeoutBlock)timeout {
    
    //启动超时计时器
    self.timeoutBlock = timeout;
    [self startTimeoutTimer:timeoutInterval];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"recv_room_id"] = pkSession.receiverRoomId;
    params[@"recv_user_id"] = pkSession.receiver.user_id;
    params[@"init_room_id"] = pkSession.initiatorRoomId;
    params[@"extends"] = pkSession.extensions; //（自定义）PK扩展数据
    QLIVELogDebug(@"===== (发起方）开始PK 参数: %@", params.description);
    
    __weak typeof(self) weakSelf = self;
    [QLiveNetworkUtil postRequestWithAction:@"client/relay/start" params:params success:^(NSDictionary * _Nonnull responseData) {
        QLIVELogDebug(@"===== (发起方）startPK 获取pkID成功！client/relay/start %@", responseData.mj_JSONString);
        /**
         返回：relay_id、relay_status、relay_token 字段
         这里 relay_id 表示：PK会话ID
         这里 relay_status 状态为0，表示：等待接受方同意
         这里 relay_token，是发送方的token
         */
        QNPKRespModel *respModel = [QNPKRespModel mj_objectWithKeyValues:responseData];
        //保存（发起方的）pkToken
        weakSelf.pkToken = respModel.pkToken;
        
        QNPKSession *initiatorSession = [[QNPKSession alloc] init];
        //PK会话ID
        initiatorSession.sessionId = respModel.sessionId;
        initiatorSession.status = (QNPKStatus)respModel.status;
        initiatorSession.receiverRoomId = pkSession.receiverRoomId;
        initiatorSession.initiatorRoomId = pkSession.initiatorRoomId;
        initiatorSession.initiator = pkSession.initiator;
        initiatorSession.receiver = pkSession.receiver;
        //保存（发起方的）pkSession
        weakSelf.pkSession = initiatorSession;
        
        //发送c2c消息（给接受PK的主播）
        [weakSelf sendStartPKMessage:initiatorSession singleMsg:YES];
        
        // (发起方）PK建连
        [weakSelf pkConnect:initiatorSession success:^{
            QLIVELogInfo(@"===== (发起方）PK建连 成功！=====");
            //停止PK超时计时器
            [weakSelf stopTimeoutTimer];
            if (success) {
                success(initiatorSession);
            }
        } failure:^(NSError * _Nonnull error) {
            QLIVELogInfo(@"===== (发起方）PK建连 失败！=====");
            //停止PK超时计时器
            [weakSelf stopTimeoutTimer];
            if (failure) {
                failure(error);
            }
        }];
    } failure:^(NSError * _Nonnull error) {
        QLIVELogError(@"===== (发起方）startPK 获取pkID失败！client/relay/start: %@", error);
        //停止PK超时计时器
        [weakSelf stopTimeoutTimer];
        if (failure) {
            failure(error);
        }
    }];
}


/**
 PK建连
 
 注意：必须有 pkToken 数据
 */
- (void)pkConnect:(QNPKSession *)pkSession success:(nullable void (^)(void))success failure:(nullable QNPKFailureBlock)failure {

    QNRoomMediaRelayConfiguration *config = [[QNRoomMediaRelayConfiguration alloc]init];
    
    QNRoomMediaRelayInfo *srcRoomInfo = [QNRoomMediaRelayInfo new];
    srcRoomInfo.roomName = self.roomInfo.title;
    srcRoomInfo.token = self.roomInfo.room_token;
    
    QNRoomMediaRelayInfo *destInfo = [QNRoomMediaRelayInfo new];
    destInfo.roomName = [self getRelayNameWithToken:self.pkToken];
    destInfo.token = self.pkToken;
    
    config.srcRoomInfo = srcRoomInfo;
    [config setDestRoomInfo:destInfo forRoomName:self.roomInfo.title];

    __weak typeof(self) weakSelf = self;
    
    //RTC（跨房轨道）转发
    [[QLive createPusherClient].rtcClient startRoomMediaRelay:config completeCallback:^(NSDictionary *state, NSError *error) {
        QLIVELogInfo(@"===== RTC（跨房轨道）转发成功！=====");
        //先通知后端"RTC跨房转发"成功
        [weakSelf reportRTCRelay:^(QNPKRespModel * respModel) {
            //更新状态
            pkSession.status = (QNPKStatus)respModel.status;
            
            //获取pk房间信息
            [weakSelf getPKInfo:pkSession.sessionId success:^(QNPKInfo * pkInfo) {
                // 把PK开始时间、扩展字段，添加到pkSession中
                pkSession.startTimeStamp = [pkInfo getStartTimeStamp];
                pkSession.extensions = pkInfo.extensions;
                //发送IM消息给观众前，PK状态设置为成功
                pkSession.status = QNPKStatusSuccess;
                QLIVELogDebug(@"===== 最终的pkSession：%@", pkSession.mj_keyValues);
                //再发group消息
                [weakSelf sendStartPKMessage:pkSession singleMsg:NO];
                QLIVELogInfo(@"===== 发送 PK开始（group）消息 =====");
                if (success) {
                    success();
                }
            } failure:failure];
        } failure:^(NSError * _Nonnull error) {
            QLIVELogError(@"===== RTC（跨房轨道）转发失败！=====");
            if (failure) {
                failure(error);
            }
        }];
    }];
}


/**
 通知后端 "RTC跨房转发" 成功
 */
- (void)reportRTCRelay:(nullable void (^)(QNPKRespModel * _Nullable))success failure:(nullable QNPKFailureBlock)failure {
    
    NSString *action = [NSString stringWithFormat:@"client/relay/%@/started",self.pkSession.sessionId];
    [QLiveNetworkUtil postRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        QLIVELogDebug(@"===== 通知后端 RTC跨房转发 成功！reportRTCRelay: %@", responseData);
        QNPKRespModel *respModel = [QNPKRespModel mj_objectWithKeyValues:responseData];
        if (success) {
            success(respModel);
        }
    } failure:^(NSError * _Nonnull error) {
        QLIVELogError(@"===== 通知后端 RTC跨房转发 失败！reportRTCRelay: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

/**
 启动PK超时计时器
 */
- (void)startTimeoutTimer:(double)timeoutInterval {
    if (!self.timeoutTimer) {
        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeoutInterval
             target:self
           selector:@selector(onTimeOut)
           userInfo:nil
            repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timeoutTimer forMode:NSRunLoopCommonModes];
    }
}

/**
 停止PK超时计时器
 */
- (void)stopTimeoutTimer
{
    if (self.timeoutTimer) {
        [self.timeoutTimer invalidate];
        self.timeoutTimer = nil;
    }
}

/**
 触发超时
 */
- (void)onTimeOut {
    //停止PK超时计时器
    [self stopTimeoutTimer];
    if (self.timeoutBlock) {
        self.timeoutBlock();
        self.timeoutBlock = nil;
    }
}

#pragma mark - （接受方）PK操作

/**
 获取（接受方的）pkToken
 */
- (void)getPKToken:(NSString *)sessionId success:(nullable void (^)(QNPKRespModel * _Nullable))success failure:(nullable QNPKFailureBlock)failure {
    NSString *action = [NSString stringWithFormat:@"client/relay/%@/token", sessionId];
    [QLiveNetworkUtil getRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        QLIVELogDebug(@"===== 获取（接受方的）pkToken 成功！ getPKToken: %@", responseData);
        QNPKRespModel *respModel = [QNPKRespModel mj_objectWithKeyValues:responseData];
        if (success) {
            success(respModel);
        }
    } failure:^(NSError * _Nonnull error) {
        QLIVELogError(@"===== 获取（接受方的）pkToken 失败！getPKToken: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - （主播端）共同的 PK操作

/**
 获取PK房间信息
 
 场景 1）：观众端，中途进PK直播间时，获取PK房间信息
 场景 2）：主播端，通知 "RTC转发成功" 上报后，互动获取一次PK房间信息
 */
- (void)getPKInfo:(NSString *)pkID success:(nullable void (^)(QNPKInfo * _Nullable))success failure:(nullable QNPKFailureBlock)failure {
    NSString *action = [NSString stringWithFormat:@"client/relay/%@", pkID];
    [QLiveNetworkUtil getRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        QLIVELogDebug(@"===== 获取PK房间信息成功：getPKInfo: %@", responseData);
        QNPKInfo *pkInfo = [QNPKInfo mj_objectWithKeyValues:responseData];
        if (success) {
            success(pkInfo);
        }
    } failure:^(NSError * _Nonnull error) {
        QLIVELogError(@"===== 获取PK房间信息失败！getPKInfo: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}


/**
 结束pk
 */
- (void)stopPK:(nullable void (^)(void))success failure:(nullable QNPKFailureBlock)failure {
    //PK结束IM消息
    [self createStopPKMessage:self.pkSession];
    //RTC转发结束
    [[QLive createPusherClient].rtcClient stopRoomMediaRelay:^(NSDictionary *state, NSError *error) {}];
    [[[QLive createPusherClient] getMixStreamManager] updateMixStreamSize:CGSizeMake(720, 1280)];
    //通知后端PK结束
    NSString *action = [NSString stringWithFormat:@"client/relay/%@/stop", self.pkSession.sessionId];
    [QLiveNetworkUtil postRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        QLIVELogDebug(@"===== 结束PK成功！stopPK: %@", responseData);
        if (success) {
            success();
        }
    } failure:^(NSError * _Nonnull error) {
        QLIVELogError(@"===== 结束PK失败！stopPK: %@", error);
        if (failure) {
            failure(error);
        }
    }];
    
    //清空数据
    self.pkToken = nil;
    self.pkSession = nil;
}

#pragma mark - （观众端）PK操作

/**
  观众进房成功事件回调
 
  观众端中途进房，如果正在PK（有pk_id字段），则获取pk直播间信息（比如：PK开始时间）
 */
- (void)onReceivePullClientJoinedRoom:(NSNotification *)notice {
    if ([notice.object isKindOfClass:[QNLiveRoomInfo class]]) {
        self.roomInfo = (QNLiveRoomInfo *)notice.object;
        if (self.roomInfo.pk_id && self.roomInfo.pk_id.length != 0) {
            __weak typeof(self) weakSelf = self;
            [self getPKInfo:self.roomInfo.pk_id success:^(QNPKInfo *pkInfo) {
                QLIVELogInfo(@"===== (观众端）获取PK房间信息成功！=====");
                // QNPKInfo -> QNPKSession
                QNPKSession *session = [pkInfo toSession];
                //代理回调，通知PK开始
                if ([weakSelf.delegate respondsToSelector:@selector(onReceiveStartPKSession:)]) {
                    [weakSelf.delegate onReceiveStartPKSession:session];
                }
            } failure:nil];
        }
    }
}

#pragma mark - Private Methods

- (NSString *)getRelayNameWithToken:(NSString *)token {
    if (token.length == 0) {
        return @"";
    }
    NSArray *arr = [token componentsSeparatedByString:@":"];
    NSString *tokenDataStr = arr.lastObject;
    NSData *data = [[NSData alloc]initWithBase64EncodedString:tokenDataStr options:0];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString *roomName = dic[@"roomName"];
    return roomName;
}

- (CreateSignalHandler *)creater {
    if (!_creater) {
        _creater = [[CreateSignalHandler alloc]initWithToId:self.roomInfo.chat_id roomId:self.roomInfo.live_id];
    }
    return _creater;
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

@end

