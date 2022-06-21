//
//  QNLiveController.m
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/30.
//

#import "QNLiveController.h"
#import "QNLivePushClient.h"
#import "QNLiveRoomClient.h"
#import "RoomHostComponent.h"
#import "OnlineUserComponent.h"
#import "BottomMenuSlot.h"
#import "QNLinkMicService.h"
#import "QNChatRoomService.h"
#import "LiveChatRoom.h"
#import "QNLiveRoomInfo.h"
#import "QNMergeOption.h"
#import "QNAlertViewController.h"
#import "QNInvitationModel.h"
#import "QRenderView.h"
#import "QLive.h"
#import "QNLiveUser.h"
#import "QNInvitationMemberListController.h"
#import "QNPKService.h"
#import "LinkInvitation.h"
#import <QNRTCKit/QNRTCKit.h>
#import "FDanmakuView.h"
#import "FDanmakuModel.h"
#import "QNIMModel.h"
#import "PubChatModel.h"

@interface QNLiveController ()<QNPushClientListener,QNRoomLifeCycleListener,QNPushClientListener,QNChatRoomServiceListener,FDanmakuViewProtocol,LiveChatRoomViewDelegate>

@property (nonatomic, strong) RoomHostComponent *roomHostSlot;
@property (nonatomic, strong) OnlineUserComponent *onlineUserSlot;
@property (nonatomic, strong) ImageButtonComponent *pubchatSlot;
@property (nonatomic, strong) BottomMenuSlot *bottomMenuSlot;
@property (nonatomic, strong) ImageButtonComponent *pkSlot;
@property (nonatomic, strong) QNLiveRoomInfo *selectPkRoomInfo;
@property (nonatomic, strong) QNPKSession *pkSession;//正在进行的pk
@property (nonatomic, strong) QNLiveUser *pk_other_user;//pk对象

@end

@implementation QNLiveController

- (void)viewDidDisappear:(BOOL)animated {
    [[QLive createPusherClient] closeRoom:self.roomInfo.live_id];
    self.chatService = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self)weakSelf = self;
    [[QLive createPusherClient] enableCamera:nil renderView:self.preview];
    [QLive createPusherClient].pushClientListener = self;
    self.danmakuView.delegate = self;
    self.chatRoomView.delegate = self;
    [self.chatService addChatServiceListener:self];
    [[QLive createPusherClient] startLive:self.roomInfo.live_id callBack:^(QNLiveRoomInfo * _Nonnull roomInfo) {
        self.roomInfo = roomInfo;
        [self updateRoomInfo];
    }];
    
    [self chatRoomView];
    [self roomHostSlot];
    [self onlineUserSlot];
    [self pubchatSlot];
    [self bottomMenuSlot];
    
    [self.chatService sendWelComeMsg:^(QNIMMessageObject * _Nonnull msg) {
        [weakSelf.chatRoomView showMessage:msg];
    }];
}

- (void)updateRoomInfo {
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[QLive createPusherClient] roomHeartBeart:weakSelf.roomInfo.live_id];
        [[QLive getRooms] getRoomInfo:weakSelf.roomInfo.live_id callBack:^(QNLiveRoomInfo * _Nonnull roomInfo) {
            weakSelf.roomInfo = roomInfo;
            [weakSelf.roomHostSlot updateWith:roomInfo];
            [weakSelf.onlineUserSlot updateWith:roomInfo];
            [weakSelf updateRoomInfo];
        }];
    });
}

#pragma mark ---------QNPushClientListener
//房间连接状态
- (void)onConnectionRoomStateChanged:(QNConnectionState)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (state == QNConnectionStateConnected) {
            [[QLive createPusherClient] beginMixStream:self.option];
        }
    });
}

- (void)onUserLeaveRTC:(NSString *)userID {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopPK];
    });
}

- (void)didStartLiveStreaming:(NSString *)streamID {
    
    [[QLive createPusherClient] updateUserAudioMergeOptions:QN_User_id trackId:[QLive createPusherClient].localAudioTrack.trackID isNeed:YES];
    CameraMergeOption *option = [CameraMergeOption new];
    if (self.roomInfo.pk_id.length == 0) {
        option.frame = CGRectMake(0, 0, 720, 1280);
    } else {
        option.frame = CGRectMake(0, 0, 720/2, 419);
    }
    option.mZ = 0;
    [[QLive createPusherClient] updateUserVideoMergeOptions:QN_User_id trackId:[QLive createPusherClient].localVideoTrack.trackID option:option];
    
}

- (void)onUserPublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for (QNRemoteTrack *track in tracks) {
            if (track.kind == QNTrackKindVideo) {
                QNRemoteVideoTrack *videoTrack = (QNRemoteVideoTrack *)track;
                QRenderView *remoteView = [[QRenderView alloc]initWithFrame:CGRectMake(SCREEN_W - 120, 120, 100, 100)];
                remoteView.userId = userID;
                remoteView.trackId = videoTrack.trackID;
                remoteView.layer.cornerRadius = 50;
                remoteView.clipsToBounds = YES;
                [self.renderBackgroundView addSubview:remoteView];
                [videoTrack play:remoteView];
                
                if (self.pk_other_user) {
                    
                    self.preview.frame = CGRectMake(0, 130, SCREEN_W/2, SCREEN_W/1.5);
                    remoteView.frame = CGRectMake(SCREEN_W/2, 130, SCREEN_W/2, SCREEN_W/1.5);
                    remoteView.layer.cornerRadius = 0;
                    [self.pkService PKStartedWithRelayID:self.pkSession.relay_id];
                              
                    [[QLive createPusherClient] updateMixStreamSize:CGSizeMake(720, 419)];
                    CameraMergeOption *userOption = [CameraMergeOption new];
                    userOption.frame = CGRectMake(720/2, 0, 720/2, 419);
                    userOption.mZ = 1;
                    [[QLive createPusherClient] updateUserVideoMergeOptions:userID trackId:videoTrack.trackID option:userOption];
                }
            } else {
                [[QLive createPusherClient] updateUserAudioMergeOptions:userID trackId:track.trackID isNeed:YES];
            }
            
        }
    });
}

#pragma mark ---------QNChatRoomServiceListener

- (void)onUserJoin:(QNLiveUser *)user message:(nonnull QNIMMessageObject *)message {
    [self.chatRoomView showMessage:message];
}

- (void)onUserLeave:(QNLiveUser *)user message:(QNIMMessageObject *)message {
    [self.chatRoomView showMessage:message];
}

//收到弹幕
- (void)onReceivedDamaku:(PubChatModel *)msg {
    FDanmakuModel *model = [[FDanmakuModel alloc]init];
    model.beginTime = 1;
    model.liveTime = 5;
    model.content = msg.content;
    model.sendNick = msg.sendUser.nick;
    model.sendAvatar = msg.sendUser.avatar;
    
    [self.danmakuView.modelsArr addObject:model];
}

-(NSTimeInterval)currentTime {
    static double time = 0;
    time += 0.1 ;
    return time;
}

- (UIView *)danmakuViewWithModel:(FDanmakuModel*)model {
    
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor whiteColor];
    label.text = model.content;
    [label sizeToFit];
    return label;
    
}

- (void)didSendMessageModel:(QNIMMessageObject *)model {
    QNIMModel *imModel = [QNIMModel mj_objectWithKeyValues:model.content.mj_keyValues];
    PubChatModel *chatModel = [PubChatModel mj_objectWithKeyValues:imModel.data];
    if ([chatModel.action isEqualToString:living_danmu]) {
        FDanmakuModel *danmuModel = [[FDanmakuModel alloc]init];
        danmuModel.beginTime = 1;
        danmuModel.liveTime = 5;
        danmuModel.content = chatModel.content;
        [self.danmakuView.modelsArr addObject:danmuModel];
    }
}

//收到下麦消息
- (void)onReceivedDownMic:(QNMicLinker *)linker {
    QRenderView *userView = [self getUserView:linker.user.user_id];
    [userView removeFromSuperview];
}

//收到公聊消息
- (void)onReceivedPuChatMsg:(PubChatModel *)msg message:(QNIMMessageObject *)message {
    [self.chatRoomView showMessage:message];
}

//收到开关视频消息
- (void)onReceivedVideoMute:(BOOL)mute user:(NSString *)uid {
    QRenderView *userView = [self getUserView:uid];
    userView.hidden = mute;
}

//收到开关音频消息
- (void)onReceivedAudioMute:(BOOL)mute user:(NSString *)uid {
    
}

//接受到连麦邀请
- (void)onReceiveLinkInvitation:(QNInvitationModel *)model {
    NSString *title = [model.invitation.msg.initiator.nick stringByAppendingString:@"申请加入连麦，是否同意？"];
    [QNAlertViewController showBaseAlertWithTitle:title content:@"" handler:^(UIAlertAction * _Nonnull action) {
        [self.chatService sendLinkMicAccept:model];
    }];
}

//接收到pk邀请
- (void)onReceivePKInvitation:(QNInvitationModel *)model {
    NSString *title = [model.invitation.msg.initiator.nick stringByAppendingString:@"邀请您PK，是否同意？"];
    [QNAlertViewController showBaseAlertWithTitle:title content:@"" handler:^(UIAlertAction * _Nonnull action) {        
        [self.chatService sendPKAccept:model];
    }];
}

//收到同意pk邀请
- (void)onReceivePKInvitationAccept:(QNInvitationModel *)model {
    
    [self.pkService startWithReceiverRoomId:model.invitation.msg.receiverRoomId receiverUid:model.invitation.msg.receiver.user_id extensions:@"" callBack:^(QNPKSession * _Nonnull pkSession) {
        
        pkSession.receiver = model.invitation.msg.receiver;
        self.pk_other_user = pkSession.receiver;
        [self.chatService createStartPKMessage:pkSession];
        
        [self beginPK:pkSession];
    }];
}

//收到开始pk信令
- (void)onReceiveStartPKSession:(QNPKSession *)pkSession {
    self.pk_other_user = pkSession.initiator;

    [self.pkService getPKToken:pkSession.relay_id callBack:^(QNPKSession * session) {
        [self beginPK:session];
    }];
    
}

//收到结束pk消息
- (void)onReceiveStopPKSession:(QNPKSession *)pkSession {
    self.pkSlot.selected = NO;
    [[QLive createPusherClient].rtcClient stopRoomMediaRelay:^(NSDictionary *state, NSError *error) {}];
    self.preview.frame = self.view.frame;
    [self.renderBackgroundView bringSubviewToFront:self.preview];
//    [self removeRemoteUserView];
    self.pk_other_user = nil;
    [[QLive createPusherClient] updateMixStreamSize:CGSizeMake(720, 1280)];
//    CameraMergeOption *option = [CameraMergeOption new];
//    option.frame = CGRectMake(0, 0, 720, 1280);
//    option.mZ = 0;
//    [[QLive createPusherClient] updateUserVideoMergeOptions:QN_User_id trackId:[QLive createPusherClient].localVideoTrack.trackID option:option];
//
}

//主动结束pk
- (void)stopPK {
    
    self.pkSlot.selected = NO;
    [[QLive createPusherClient].rtcClient stopRoomMediaRelay:^(NSDictionary *state, NSError *error) {}];
    [self.pkService stopWithRelayID:self.pkSession.relay_id callBack:^{}];
    [self.chatService createStopPKMessage:self.pkSession receiveUser:self.pk_other_user];
    self.preview.frame = self.view.frame;
    [self.renderBackgroundView bringSubviewToFront:self.preview];
//    [self removeRemoteUserView];
    self.pk_other_user = nil;
    [[QLive createPusherClient] updateMixStreamSize:CGSizeMake(720, 1280)];
//    CameraMergeOption *option = [CameraMergeOption new];
//    option.frame = CGRectMake(0, 0, 720, 1280);
//    option.mZ = 0;
//    [[QLive createPusherClient] updateUserVideoMergeOptions:QN_User_id trackId:[QLive createPusherClient].localVideoTrack.trackID option:option];
}



- (void)beginPK:(QNPKSession *)pkSession {
    
    self.pkSession = pkSession;
    self.pkSlot.selected = YES;
    QNRoomMediaRelayConfiguration *config = [[QNRoomMediaRelayConfiguration alloc]init];
    
    QNRoomMediaRelayInfo *srcRoomInfo = [QNRoomMediaRelayInfo new];
    srcRoomInfo.roomName = self.roomInfo.title;
    srcRoomInfo.token = self.roomInfo.room_token;
    
    QNRoomMediaRelayInfo *destInfo = [QNRoomMediaRelayInfo new];
    destInfo.roomName = [self getRelayNameWithToken:self.pkSession.relay_token];
    destInfo.token = self.pkSession.relay_token;
    
    config.srcRoomInfo = srcRoomInfo;
    [config setDestRoomInfo:destInfo forRoomName:self.roomInfo.title];

    [[QLive createPusherClient].rtcClient startRoomMediaRelay:config completeCallback:^(NSDictionary *state, NSError *error) {

    }];
    
}

- (NSString *)getRelayNameWithToken:(NSString *)token {
    NSArray *arr = [token componentsSeparatedByString:@":"];
    NSString *tokenDataStr = arr.lastObject;
    NSData *data = [[NSData alloc]initWithBase64EncodedString:tokenDataStr options:0];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//    NSString *appId = dic[@"appId"];
    NSString *roomName = dic[@"roomName"];
//    NSString *userId = dic[@"userId"];
    return roomName;
}



//自己是否是房主
- (BOOL)isAdmin {
    BOOL isAdmin = NO;
    if ([self.roomInfo.anchor_info.user_id isEqualToString:QN_User_id]) {
        isAdmin = YES;
    }
    return isAdmin;
}

- (RoomHostComponent *)roomHostSlot {
    if (!_roomHostSlot) {
        _roomHostSlot = [[RoomHostComponent alloc]init];
        [_roomHostSlot createDefaultView:CGRectMake(20, 60, 135, 40) onView:self.view];
        [_roomHostSlot updateWith:self.roomInfo];;
        _roomHostSlot.clickBlock = ^(BOOL selected) {
            NSLog(@"点击了房主头像");
        };
    }
    return _roomHostSlot;
}

- (OnlineUserComponent *)onlineUserSlot {
    if (!_onlineUserSlot) {
        _onlineUserSlot = [[OnlineUserComponent alloc]init];
       [_onlineUserSlot createDefaultView:CGRectMake(self.view.frame.size.width - 150, 60, 150, 60) onView:self.view];
        [_onlineUserSlot updateWith:self.roomInfo];
        _onlineUserSlot.clickBlock = ^(BOOL selected){
            NSLog(@"点击了在线人数");
        };
    }
    return _onlineUserSlot;
}

- (ImageButtonComponent *)pubchatSlot {
    if (!_pubchatSlot) {
        _pubchatSlot = [[ImageButtonComponent alloc]init];
        [_pubchatSlot createDefaultView:CGRectMake(15, SCREEN_H - 80, 220, 45) onView:self.view];
        [_pubchatSlot normalImage:@"chat_input_bar" selectImage:@"chat_input_bar"];
        __weak typeof(self)weakSelf = self;
        _pubchatSlot.clickBlock = ^(BOOL selected){
            [weakSelf.chatRoomView commentBtnPressedWithPubchat:YES];
            NSLog(@"点击了公聊");
        };
        
    }
    return _pubchatSlot;
}

- (BottomMenuSlot *)bottomMenuSlot {
    if (!_bottomMenuSlot) {
        NSMutableArray *slotList = [NSMutableArray array];
        __weak typeof(self)weakSelf = self;
        
        ImageButtonComponent *pk = [[ImageButtonComponent alloc]init];
        [pk normalImage:@"pk" selectImage:@"end_pk"];
        pk.clickBlock = ^(BOOL selected){
            NSLog(@"点击了pk");
            if (!selected) {
                [[QLive getRooms] listRoom:1 pageSize:20 callBack:^(NSArray<QNLiveRoomInfo *> * _Nonnull list) {
                    
                    [weakSelf popInvitationPKView:list];
                }];
            } else {
                [weakSelf stopPK];
            }
        };
        [slotList addObject:pk];
        self.pkSlot = pk;
        
        ImageButtonComponent *message = [[ImageButtonComponent alloc]init];
        [message normalImage:@"message" selectImage:@"message"];
        message.clickBlock = ^(BOOL selected){
            [weakSelf.chatRoomView commentBtnPressedWithPubchat:NO];
            NSLog(@"点击了私信");
        };
        [slotList addObject:message];
        
        ImageButtonComponent *close = [[ImageButtonComponent alloc]init];
        [close normalImage:@"live_close" selectImage:@"live_close"];
        close.clickBlock = ^(BOOL selected){
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            NSLog(@"点击了关闭");
        };
        [slotList addObject:close];
        
        _bottomMenuSlot = [[BottomMenuSlot alloc]init];
        _bottomMenuSlot.slotList = slotList.copy;
        [_bottomMenuSlot createDefaultView:CGRectMake(240, SCREEN_H - 80, SCREEN_W - 240, 45) onView:self.view];
           
    }
    return _bottomMenuSlot;
}

- (void)popInvitationPKView:(NSArray<QNLiveRoomInfo *> *)list {
    
    QNInvitationMemberListController *vc = [[QNInvitationMemberListController alloc] initWithList:list];
    __weak typeof(self)weakSelf = self;
    vc.invitationClickedBlock = ^(QNLiveRoomInfo * _Nonnull itemModel) {
       
        [weakSelf.chatService sendPKInvitation:itemModel.live_id receiveUser:itemModel.anchor_info];
        weakSelf.selectPkRoomInfo = itemModel;
    };
    
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(240);
        make.bottom.equalTo(self.view);
    }];
}

@end
