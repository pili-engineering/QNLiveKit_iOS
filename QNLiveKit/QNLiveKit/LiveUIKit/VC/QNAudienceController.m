//
//  QNAudienceController.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/6.
//

#import "QNAudienceController.h"
#import "RoomHostView.h"
#import "OnlineUserView.h"
#import "BottomMenuView.h"
#import "QNChatRoomService.h"
#import "LiveChatRoom.h"
#import "QNLiveRoomInfo.h"
#import "QNLiveRoomClient.h"
#import <PLPlayerKit/PLPlayerKit.h>
#import "LinkStateView.h"
#import "QRenderView.h"
#import "QNLiveUser.h"
#import "FDanmakuView.h"
#import "FDanmakuModel.h"
#import "QIMModel.h"
#import "PubChatModel.h"
#import "QToastView.h"
#import <QNIMSDK/QNIMSDK.h>
#import "QLinkMicService.h"

@interface QNAudienceController ()<QNChatRoomServiceListener,QNPushClientListener,LiveChatRoomViewDelegate,FDanmakuViewProtocol,PLPlayerDelegate>

@property (nonatomic, strong) PLPlayer *player;

@end

@implementation QNAudienceController

- (void)viewDidDisappear:(BOOL)animated {
    [self.chatService removeChatServiceListener];
    [[QLive createPlayerClient] leaveRoom:self.roomInfo.live_id];   
}

- (void)viewWillAppear:(BOOL)animated {
    self.preview.frame = CGRectZero;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    __weak typeof(self)weakSelf = self;
    [self.chatService addChatServiceListener:self];
    self.chatRoomView.delegate = self;
    self.danmakuView.delegate = self;
    [[QLive createPlayerClient] joinRoom:self.roomInfo.live_id callBack:^(QNLiveRoomInfo * _Nonnull roomInfo) {
        weakSelf.roomInfo = roomInfo;
        [self playWithUrl:roomInfo.rtmp_url];
        [weakSelf updateRoomInfo];
    }];
    
    [self roomHostView];
    [self onlineUserView];
    [self pubchatView];
    [self bottomMenuView];
    
    [self.chatService sendWelComeMsg:^(QNIMMessageObject * _Nonnull msg) {
        [weakSelf.chatRoomView showMessage:msg];
    }];
}

- (void)playWithUrl:(NSString *)url {
    PLPlayerOption *option = [PLPlayerOption defaultOption];
    PLPlayFormat format = kPLPLAY_FORMAT_UnKnown;
    
    [option setOptionValue:@(format) forKey:PLPlayerOptionKeyVideoPreferFormat];
    [option setOptionValue:@(kPLLogNone) forKey:PLPlayerOptionKeyLogLevel];
    
    self.player = [PLPlayer playerWithURL:[NSURL URLWithString:url] option:option];
    [self.view insertSubview:self.player.playerView atIndex:2];
    if (self.roomInfo.pk_id.length == 0) {
        self.player.playerView.frame = self.view.frame;
    } else {
        self.player.playerView.frame = CGRectMake(0, 150, SCREEN_W, SCREEN_W *0.6);
    }
    self.player.delegate = self;
    self.player.delegateQueue = dispatch_get_main_queue();
    [self.player play];
}

- (void)player:(nonnull PLPlayer *)player width:(int)width height:(int)height {
    if (height > 500) {
        self.player.playerView.frame = self.view.frame;
    } else {
        self.player.playerView.frame = CGRectMake(0, 150, SCREEN_W, SCREEN_W *0.6);
    }
}

- (void)stopPlay {
    [self.player stop];
    [self.player.playerView  removeFromSuperview];
}

- (void)updateRoomInfo {
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
            self.preview.frame = CGRectMake(SCREEN_W - 120, 120, 100, 100);
            self.preview.layer.cornerRadius = 50;
            self.preview.clipsToBounds = YES;
            [[QLive createPusherClient] enableCamera:nil renderView:self.preview];
            [self popLinkSLot];

        }
    });
   
}

- (void)onUserPublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (QNRemoteTrack *track in tracks) {
            if (track.kind == QNTrackKindVideo) {
                
                QRenderView *remoteView = [[QRenderView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H)];
                remoteView.userId = userID;
                remoteView.trackId = track.trackID;
                [self.renderBackgroundView insertSubview:remoteView atIndex:0];
                [(QNRemoteVideoTrack *)track play:remoteView];
            } else {
            }
        }
    });
}

- (void)onUserJoin:(QNLiveUser *)user message:(nonnull QNIMMessageObject *)message {
    [self.chatRoomView showMessage:message];
}

- (void)onUserLeave:(QNLiveUser *)user message:(QNIMMessageObject *)message {
    [self.chatRoomView showMessage:message];
}

- (void)onReceivedPuChatMsg:(PubChatModel *)msg message:(QNIMMessageObject *)message {
    [self.chatRoomView showMessage:message];
}

//连麦邀请被接受
- (void)onReceiveLinkInvitationAccept:(QInvitationModel *)model {
    [QToastView showToast:@"主播同意了你的连麦申请"];
    [[QLive createPusherClient] enableCamera:nil renderView:self.preview];
    [QLive createPusherClient].pushClientListener = self;
    [self.linkService onMic:YES camera:YES extends:nil];
    [self stopPlay];
}

//收到开始pk信令
- (void)onReceiveStartPKSession:(QNPKSession *)pkSession {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self replayPlayer];
     });
}

//收到结束pk信令
- (void)onReceiveStopPKSession:(QNPKSession *)pkSession {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self replayPlayer];
     });
}

- (void)replayPlayer {
    [self.player pause];
    [self.player resume];
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



- (RoomHostView *)roomHostView {
    if (!_roomHostView) {
        _roomHostView = [[RoomHostView alloc]init];
        [_roomHostView createDefaultView:CGRectMake(20, 60, 135, 40) onView:self.view];
        [_roomHostView updateWith:self.roomInfo];;
        _roomHostView.clickBlock = ^(BOOL selected){
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
        
        ImageButtonView *link = [[ImageButtonView alloc]init];
        [link bundleNormalImage:@"link" selectImage:@"link"];
        link.clickBlock = ^(BOOL selected){
            
            [weakSelf.chatService sendLinkMicInvitation:weakSelf.roomInfo.anchor_info];
            [QToastView showToast:@"连麦申请已发送"];
            NSLog(@"点击了连麦");
        };
        [slotList addObject:link];
        
        ImageButtonView *message = [[ImageButtonView alloc]init];
        [message bundleNormalImage:@"message" selectImage:@"message"];
        message.clickBlock = ^(BOOL selected){
            [weakSelf.chatRoomView commentBtnPressedWithPubchat:NO];
            NSLog(@"点击了私信");
        };
        [slotList addObject:message];
        
        ImageButtonView *close = [[ImageButtonView alloc]init];
        [close bundleNormalImage:@"live_close" selectImage:@"live_close"];
        close.clickBlock = ^(BOOL selected){
            [weakSelf.chatService sendLeaveMsg];
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            NSLog(@"点击了关闭");
        };
        [slotList addObject:close];
        
        _bottomMenuView = [[BottomMenuView alloc]init];
        _bottomMenuView.slotList = slotList.copy;
        [_bottomMenuView createDefaultView:CGRectMake(240, SCREEN_H - 80, SCREEN_W - 240, 45) onView:self.view];

    }
    return _bottomMenuView;
}

- (void)popLinkSLot {
    _linkSView = [[LinkStateView alloc]init];
    [_linkSView createDefaultView:CGRectMake(0, SCREEN_H - 230, SCREEN_W, 230) onView:self.view];
    __weak typeof(self)weakSelf = self;
    _linkSView.microphoneBlock = ^(BOOL mute) {
        [[QLive createPusherClient] muteMicrophone:mute];
        
        [weakSelf.linkService updateMicStatusType:@"mic" flag:!mute];
        
    };
    _linkSView.cameraBlock = ^(BOOL mute) {
        [weakSelf.linkService updateMicStatusType:@"camera" flag:!mute];
    };
    _linkSView.clickBlock = ^(BOOL selected){
        
        [weakSelf.linkService downMic];
        weakSelf.preview.frame = CGRectZero;
        for (QRenderView *userView in weakSelf.renderBackgroundView.subviews) {
            if (![userView.userId isEqualToString:QN_User_id]) {
                [userView removeFromSuperview];
            }
        }
        [weakSelf playWithUrl:weakSelf.roomInfo.rtmp_url];
        NSLog(@"点击了结束连麦");
    };
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


@end
