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
#import "QLinkMicService.h"
#import "QNChatRoomService.h"
#import "LiveChatRoom.h"
#import "QNLiveRoomInfo.h"
#import "QNMergeOption.h"
#import "QAlertView.h"
#import "QInvitationModel.h"
#import "QRenderView.h"
#import "QLive.h"
#import "QNLiveUser.h"
#import "QNInvitationMemberListController.h"
#import "QPKService.h"
#import "LinkInvitation.h"
#import <QNRTCKit/QNRTCKit.h>
#import "FDanmakuView.h"
#import "FDanmakuModel.h"
#import "QIMModel.h"
#import "PubChatModel.h"
#import "QToastView.h"
#import <QNIMSDK/QNIMSDK.h>
#import "GoodsSellListController.h"
#import "GoodsModel.h"
#import "QLiveNetworkUtil.h"


@interface QLiveController ()<QNPushClientListener,QNRoomLifeCycleListener,QNPushClientListener,QNChatRoomServiceListener,FDanmakuViewProtocol,LiveChatRoomViewDelegate,MicLinkerListener,PKServiceListener>

@property (nonatomic, strong) QNLiveRoomInfo *selectPkRoomInfo;
@property (nonatomic, strong) QNPKSession *pkSession;//正在进行的pk
@property (nonatomic, strong) QNLiveUser *pk_other_user;//pk对象
@property (nonatomic, strong) ImageButtonView *pkSlot;

@end

@implementation QLiveController


- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self)weakSelf = self;
    [[QLive createPusherClient] enableCamera:nil renderView:self.preview];
    [QLive createPusherClient].pushClientListener = self;
    self.linkService.micLinkerListener = self;
    self.pkService.delegate = self;
    self.danmakuView.delegate = self;
    self.chatRoomView.delegate = self;
    [self.chatService addChatServiceListener:self];
    [[QLive createPusherClient] startLive:self.roomInfo.live_id callBack:^(QNLiveRoomInfo * _Nonnull roomInfo) {
        self.roomInfo = roomInfo;
        [self updateRoomInfo];
    }];
    
    [self roomHostView];
    [self onlineUserView];
    [self pubchatView];
    [self bottomMenuView];
    
    [self.chatService sendWelComeMsg:^(QNIMMessageObject * _Nonnull msg) {
        [weakSelf.chatRoomView showMessage:msg];
    }];
}

- (void)updateRoomInfo {
    [[QLive createPusherClient] roomHeartBeart:self.roomInfo.live_id];
    [[QLive getRooms] getRoomInfo:self.roomInfo.live_id callBack:^(QNLiveRoomInfo * _Nonnull roomInfo) {
        self.roomInfo = roomInfo;
        [self.roomHostView updateWith:roomInfo];
        [self.onlineUserView updateWith:roomInfo];
    }];
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf updateRoomInfo];
    });
}

#pragma mark ---------QNPushClientListener
//房间连接状态
- (void)onConnectionRoomStateChanged:(QNConnectionState)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (state == QNConnectionStateConnected) {

        } else if (state == QNConnectionStateDisconnected) {
            [self.chatService sendLeaveMsg];
            [[QLive createPusherClient] closeRoom];
            [QToastView showToast:@"您已离线"];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
    });
}

- (void)onUserLeaveRTC:(NSString *)userID {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.pk_other_user) {
            [self stopPK];
        }
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
    QIMModel *imModel = [QIMModel mj_objectWithKeyValues:model.content.mj_keyValues];
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
- (void)onReceiveLinkInvitation:(QInvitationModel *)model {
    NSString *title = [model.invitation.msg.initiator.nick stringByAppendingString:@"申请加入连麦，是否同意？"];
    [QAlertView showBaseAlertWithTitle:title content:@"" handler:^(UIAlertAction * _Nonnull action) {
        [self.linkService AcceptLink:model];
    }];
}

//接收到pk邀请
- (void)onReceivePKInvitation:(QInvitationModel *)model {
    NSString *title = [model.invitation.msg.initiator.nick stringByAppendingString:@"邀请您PK，是否同意？"];
    [QAlertView showBaseAlertWithTitle:title content:@"" handler:^(UIAlertAction * _Nonnull action) {        
        [self.pkService AcceptPK:model];
        self.pk_other_user = model.invitation.msg.initiator;
    }];
}

//收到同意pk邀请
- (void)onReceivePKInvitationAccept:(QNPKSession *)model {
    [QToastView showToast:@"对方主播同意pk"];
    self.pkSlot.selected = YES;
    self.pk_other_user = model.receiver;
}

//收到开始pk信令
- (void)onReceiveStartPKSession:(QNPKSession *)pkSession {
    [QToastView showToast:@"pk马上开始"];
    self.pk_other_user = pkSession.initiator;
    self.pkSlot.selected = YES;
}

//收到结束pk消息
- (void)onReceiveStopPKSession:(QNPKSession *)pkSession {
    [self stopPK];
}

//主动结束pk
- (void)stopPK {
    self.pkSlot.selected = NO;
    self.preview.frame = self.view.frame;
    [self.renderBackgroundView bringSubviewToFront:self.preview];
    self.pk_other_user = nil;
    [self.pkService stopPK:nil];
}

- (RoomHostView *)roomHostView {
    if (!_roomHostView) {
        _roomHostView = [[RoomHostView alloc]initWithFrame:CGRectMake(20, 60, 135, 40)];
        [self.view addSubview:_roomHostView];
        [_roomHostView updateWith:self.roomInfo];;
        _roomHostView.clickBlock = ^(BOOL selected) {
            NSLog(@"点击了房主头像");
        };
    }
    return _roomHostView;
}

- (OnlineUserView *)onlineUserView {
    if (!_onlineUserView) {
        _onlineUserView = [[OnlineUserView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 150, 60, 150, 60)];
        [self.view addSubview:_onlineUserView];
        [_onlineUserView updateWith:self.roomInfo];
        _onlineUserView.clickBlock = ^(BOOL selected){
            NSLog(@"点击了在线人数");
        };
    }
    return _onlineUserView;
}

- (ImageButtonView *)pubchatView {
    if (!_pubchatView) {
        _pubchatView = [[ImageButtonView alloc]initWithFrame:CGRectMake(15, SCREEN_H - 60, 170, 45)];
        [self.view addSubview:_pubchatView];
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
        ImageButtonView *pk = [[ImageButtonView alloc]initWithFrame:CGRectZero];
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
        
        //购物车
        ImageButtonView *shopping = [[ImageButtonView alloc]initWithFrame:CGRectZero];
        [shopping bundleNormalImage:@"shopping" selectImage:@"shopping"];
        shopping.clickBlock = ^(BOOL selected){
            [weakSelf popGoodListView];            
        };
        [slotList addObject:shopping];
        
        //弹幕
        ImageButtonView *message = [[ImageButtonView alloc]initWithFrame:CGRectZero];
        [message bundleNormalImage:@"message" selectImage:@"message"];
        message.clickBlock = ^(BOOL selected){
            [weakSelf.chatRoomView commentBtnPressedWithPubchat:NO];
        };
        [slotList addObject:message];
        //关闭
        ImageButtonView *close = [[ImageButtonView alloc]initWithFrame:CGRectZero];
        [close bundleNormalImage:@"live_close" selectImage:@"live_close"];
        close.clickBlock = ^(BOOL selected){
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        };
        [slotList addObject:close];
        
        _bottomMenuView = [[BottomMenuView alloc]initWithFrame:CGRectMake(200, SCREEN_H - 60, SCREEN_W - 200, 45)];
        [_bottomMenuView updateWithSlotList:slotList.copy];
        [self.view addSubview:_bottomMenuView];
    }
    return _bottomMenuView;
}

- (void)popGoodListView {

        GoodsSellListController *vc = [[GoodsSellListController alloc] initWithLiveID:self.roomInfo.live_id];
        vc.view.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self addChildViewController:vc];
        [self.view addSubview:vc.view];
        

}

//邀请面板
- (void)popInvitationPKView:(NSArray<QNLiveRoomInfo *> *)list {
    
    NSArray<QNLiveRoomInfo *> *resultList = [self filterListWithList:list];
    QNInvitationMemberListController *vc = [[QNInvitationMemberListController alloc] initWithList:resultList];
    __weak typeof(self)weakSelf = self;
    vc.invitationClickedBlock = ^(QNLiveRoomInfo * _Nonnull itemModel) {
       
        [weakSelf.pkService applyPK:itemModel.live_id receiveUser:itemModel.anchor_info];
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

 //筛除掉自己的直播间
- (NSArray<QNLiveRoomInfo *> *)filterListWithList:(NSArray<QNLiveRoomInfo *> *)list{
    NSMutableArray *resultList = [NSMutableArray array];
    for (QNLiveRoomInfo *room in list) {
        if (![room.anchor_info.user_id isEqualToString:QN_User_id]) {
            [resultList addObject:room];
        }
    }
    return resultList;
}

@end
