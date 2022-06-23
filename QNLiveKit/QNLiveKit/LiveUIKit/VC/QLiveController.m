//
//  QLiveController.m
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/30.
//

#import "QLiveController.h"
#import "QNLivePushClient.h"
#import "QNLiveRoomClient.h"
#import "RoomHostView.h"
#import "OnlineUserView.h"
#import "BottomMenuView.h"
#import "QNLinkMicService.h"
#import "QNChatRoomService.h"
#import "LiveChatRoom.h"
#import "QNLiveRoomInfo.h"
#import "QNMergeOption.h"
#import "QAlertView.h"
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
#import "QToastView.h"
#import <QNIMSDK/QNIMSDK.h>

@interface QLiveController ()<QNPushClientListener,QNRoomLifeCycleListener,QNPushClientListener,QNChatRoomServiceListener,FDanmakuViewProtocol,LiveChatRoomViewDelegate>

@property (nonatomic, strong) QNLiveRoomInfo *selectPkRoomInfo;
@property (nonatomic, strong) QNPKSession *pkSession;//正在进行的pk
@property (nonatomic, strong) QNLiveUser *pk_other_user;//pk对象
@property (nonatomic, strong) ImageButtonView *pkSlot;

@end

@implementation QLiveController

- (void)viewDidDisappear:(BOOL)animated {
    [self.chatService removeChatServiceListener];
    [[QLive createPusherClient] closeRoom:self.roomInfo.live_id];
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
    [self roomHostView];
    [self onlineUserView];
    [self pubchatView];
    [self bottomMenuView];
    
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
            [weakSelf.roomHostView updateWith:roomInfo];
            [weakSelf.onlineUserView updateWith:roomInfo];
            [weakSelf updateRoomInfo];
        }];
    });
}

#pragma mark ---------QNPushClientListener
//房间连接状态
- (void)onConnectionRoomStateChanged:(QNConnectionState)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (state == QNConnectionStateConnected) {

        } else if (state == QNConnectionStateDisconnected) {
            [self.chatService sendLeaveMsg];
            [[QLive createPusherClient] closeRoom:self.roomInfo.live_id];
            [QToastView showToast:@"您已离线"];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
    });
}

- (void)onUserLeaveRTC:(NSString *)userID {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopPK];
    });
}

- (void)didStartLiveStreaming:(NSString *)streamID {    
    //更新自己的混流布局
    if (self.pk_other_user) {
        CameraMergeOption *option = [CameraMergeOption new];
        option.frame = CGRectMake(0, 0, 720/2, 419);
        option.mZ = 0;
        [[[QLive createPusherClient] getMixStreamManager] updateUserVideoMixStreamingWithTrackId:[QLive createPusherClient].localVideoTrack.trackID option:option];
    }
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
                              
                    [[[QLive createPusherClient] getMixStreamManager] updateMixStreamSize:CGSizeMake(720, 419)];
                    CameraMergeOption *userOption = [CameraMergeOption new];
                    userOption.frame = CGRectMake(720/2, 0, 720/2, 419);
                    userOption.mZ = 0;
                    [[[QLive createPusherClient] getMixStreamManager] updateUserVideoMixStreamingWithTrackId:videoTrack.trackID option:userOption];
                    
                } else {
                    
                    [[[QLive createPusherClient] getMixStreamManager] updateMixStreamSize:CGSizeMake(720, 1280)];
                    CameraMergeOption *userOption = [CameraMergeOption new];
                    userOption.frame = CGRectMake(720-184-30, 200, 184, 184);
                    userOption.mZ = 1;
                    [[[QLive createPusherClient] getMixStreamManager] updateUserVideoMixStreamingWithTrackId:videoTrack.trackID option:userOption];
                }
                
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
    [QAlertView showBaseAlertWithTitle:title content:@"" handler:^(UIAlertAction * _Nonnull action) {
        [self.chatService sendLinkMicAccept:model];
    }];
}

//接收到pk邀请
- (void)onReceivePKInvitation:(QNInvitationModel *)model {
    NSString *title = [model.invitation.msg.initiator.nick stringByAppendingString:@"邀请您PK，是否同意？"];
    [QAlertView showBaseAlertWithTitle:title content:@"" handler:^(UIAlertAction * _Nonnull action) {        
        [self.chatService sendPKAccept:model];
    }];
}

//收到同意pk邀请
- (void)onReceivePKInvitationAccept:(QNInvitationModel *)model {
    
    [QToastView showToast:@"对方主播同意pk"];
    
    [self.pkService startWithReceiverRoomId:model.invitation.msg.receiverRoomId receiverUid:model.invitation.msg.receiver.user_id extensions:@"" callBack:^(QNPKSession * _Nonnull pkSession) {
        
        pkSession.receiver = model.invitation.msg.receiver;
        self.pk_other_user = pkSession.receiver;
        [self.chatService createStartPKMessage:pkSession singleMsg:YES];
        [self beginPK:pkSession];
    }];
}

//收到开始pk信令
- (void)onReceiveStartPKSession:(QNPKSession *)pkSession {
    if (self.pk_other_user) {
        return;
    }
    self.pk_other_user = pkSession.initiator;
    [self.pkService getPKToken:pkSession.relay_id callBack:^(QNPKSession * session) {
        [self beginPK:session];
    }];
}

//收到结束pk消息
- (void)onReceiveStopPKSession:(QNPKSession *)pkSession {
    [self stopRelay];
}

//主动结束pk
- (void)stopPK {
    [self stopRelay];
    [self.chatService createStopPKMessage:self.pkSession];
    [self.pkService stopWithRelayID:self.pkSession.relay_id callBack:^{}];
}

- (void)stopRelay {
    self.pkSlot.selected = NO;
    [[QLive createPusherClient].rtcClient stopRoomMediaRelay:^(NSDictionary *state, NSError *error) {}];
    self.preview.frame = self.view.frame;
    [self.renderBackgroundView bringSubviewToFront:self.preview];
//    [self removeRemoteUserView];
    self.pk_other_user = nil;
    [[[QLive createPusherClient] getMixStreamManager] updateMixStreamSize:CGSizeMake(720, 1280)];
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

    __weak typeof(self)weakSelf = self;
    [[QLive createPusherClient].rtcClient startRoomMediaRelay:config completeCallback:^(NSDictionary *state, NSError *error) {
        
        [weakSelf.chatService createStartPKMessage:pkSession singleMsg:NO];
        
    }];
    
}

- (NSString *)getRelayNameWithToken:(NSString *)token {
    NSArray *arr = [token componentsSeparatedByString:@":"];
    NSString *tokenDataStr = arr.lastObject;
    NSData *data = [[NSData alloc]initWithBase64EncodedString:tokenDataStr options:0];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString *roomName = dic[@"roomName"];
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

- (RoomHostView *)roomHostView {
    if (!_roomHostView) {
        _roomHostView = [[RoomHostView alloc]init];
        [_roomHostView createDefaultView:CGRectMake(20, 60, 135, 40) onView:self.view];
        [_roomHostView updateWith:self.roomInfo];;
        _roomHostView.clickBlock = ^(BOOL selected) {
            NSLog(@"点击了房主头像");
        };
    }
    return _roomHostView;
}

- (OnlineUserView *)onlineUserView {
    if (!_onlineUserView) {
        _onlineUserView = [[OnlineUserView alloc]init];
       [_onlineUserView createDefaultView:CGRectMake(self.view.frame.size.width - 150, 60, 150, 60) onView:self.view];
        [_onlineUserView updateWith:self.roomInfo];
        _onlineUserView.clickBlock = ^(BOOL selected){
            NSLog(@"点击了在线人数");
        };
    }
    return _onlineUserView;
}

- (ImageButtonView *)pubchatView {
    if (!_pubchatView) {
        _pubchatView = [[ImageButtonView alloc]init];
        [_pubchatView createDefaultView:CGRectMake(15, SCREEN_H - 80, 220, 45) onView:self.view];
        [_pubchatView bundleNormalImage:@"chat_input_bar" selectImage:@"chat_input_bar"];
        __weak typeof(self)weakSelf = self;
        _pubchatView.clickBlock = ^(BOOL selected){
            [weakSelf.chatRoomView commentBtnPressedWithPubchat:YES];
            NSLog(@"点击了公聊");
        };
    }
    return _pubchatView;
}

- (BottomMenuView *)bottomMenuView {
    if (!_bottomMenuView) {
        NSMutableArray *slotList = [NSMutableArray array];
        __weak typeof(self)weakSelf = self;
        //pk
        ImageButtonView *pk = [[ImageButtonView alloc]init];
        [pk bundleNormalImage:@"pk" selectImage:@"end_pk"];
        pk.clickBlock = ^(BOOL selected){
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
        //弹幕
        ImageButtonView *message = [[ImageButtonView alloc]init];
        [message bundleNormalImage:@"message" selectImage:@"message"];
        message.clickBlock = ^(BOOL selected){
            [weakSelf.chatRoomView commentBtnPressedWithPubchat:NO];
        };
        [slotList addObject:message];
        //关闭
        ImageButtonView *close = [[ImageButtonView alloc]init];
        [close bundleNormalImage:@"live_close" selectImage:@"live_close"];
        close.clickBlock = ^(BOOL selected){
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        };
        [slotList addObject:close];
        
        _bottomMenuView = [[BottomMenuView alloc]init];
        _bottomMenuView.slotList = slotList.copy;
        [_bottomMenuView createDefaultView:CGRectMake(240, SCREEN_H - 80, SCREEN_W - 240, 45) onView:self.view];
    }
    return _bottomMenuView;
}

//邀请面板
- (void)popInvitationPKView:(NSArray<QNLiveRoomInfo *> *)list {
    
    QNInvitationMemberListController *vc = [[QNInvitationMemberListController alloc] initWithList:list];
    __weak typeof(self)weakSelf = self;
    vc.invitationClickedBlock = ^(QNLiveRoomInfo * _Nonnull itemModel) {
       
        [weakSelf.chatService sendPKInvitation:itemModel.live_id receiveUser:itemModel.anchor_info];
        weakSelf.selectPkRoomInfo = itemModel;
        [QToastView showToast:@"pk邀请已发送"];
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
