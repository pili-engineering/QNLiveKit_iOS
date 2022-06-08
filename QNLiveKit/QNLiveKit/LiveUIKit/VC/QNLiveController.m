//
//  QNLiveController.m
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/30.
//

#import "QNLiveController.h"
#import "QNLivePushClient.h"
#import "QNLiveRoomClient.h"
#import "RoomHostSlot.h"
#import "OnlineUserSlot.h"
#import "BottomMenuSlot.h"
#import "QNLinkMicService.h"
#import "QNChatRoomService.h"
#import "LiveChatRoom.h"
#import "QNLiveRoomInfo.h"
#import "QNMergeOption.h"
#import "QNAlertViewController.h"
#import "QNInvitationModel.h"
#import "RemoteUserVIew.h"
#import "QNLiveRoomEngine.h"
#import "QNInvitationMemberListController.h"
#import "QNPKService.h"
#import "LinkInvitation.h"

@interface QNLiveController ()<QNPushClientListener,QNRoomLifeCycleListener,QNPushClientListener,QNChatRoomServiceListener>

@property (nonatomic, strong) RoomHostSlot *roomHostSlot;
@property (nonatomic, strong) OnlineUserSlot *onlineUserSlot;
@property (nonatomic, strong) BottomMenuSlot *bottomMenuSlot;

@property (nonatomic, copy) NSString *relayId;
@property (nonatomic, strong) QNLiveRoomInfo *selectPkRoomInfo;
@end

@implementation QNLiveController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self)weakSelf = self;
    [self.roomClient addRoomLifeCycleListener:self];
    [self.pushClient addPushClientListener:self];
    [self.chatService addChatServiceListener:self];
    [self.roomClient startLive:^(QNLiveRoomInfo * _Nonnull roomInfo) {
        weakSelf.roomInfo = roomInfo;
    }];
    
    [self chatRoomView];
    [self roomHostSlot];
    [self onlineUserSlot];
    [self bottomMenuSlot];
    
    [self.chatService sendWelComeMsg:^(QNIMMessageObject * _Nonnull msg) {
        [weakSelf.chatRoomView showMessage:msg];
    }];
}

#pragma mark ---------QNPushClientListener
//房间连接状态
- (void)onConnectionRoomStateChanged:(QNConnectionState)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (state == QNConnectionStateConnected) {
            self.preview.hidden = NO;
            [self.pushClient setLocalPreView:self.preview];
            [self.pushClient publishCameraAndMicrophone:^(BOOL onPublished, NSError * _Nonnull error) {

            }];
            [self.roomClient roomHeartBeart];
        }
    });
}

- (void)onUserPublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (QNRemoteTrack *track in tracks) {
            if (track.kind == QNTrackKindVideo) {
                self.pushClient.remoteCameraTrack = track;
                RemoteUserVIew *remoteView = [[RemoteUserVIew alloc]initWithFrame:CGRectMake(SCREEN_W - 120, 120, 100, 100)];
                remoteView.userId = userID;
                remoteView.trackId = track.trackID;
                [self.renderBackgroundView addSubview:remoteView];
                [self.pushClient.remoteCameraTrack play:remoteView];
            } else {
                self.pushClient.remoteAudioTrack = track;
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

//收到下麦消息
- (void)onReceivedDownMic:(QNMicLinker *)linker {
    for (RemoteUserVIew *userView in self.renderBackgroundView.subviews) {
        if ([userView.class isEqual:[RemoteUserVIew class]]) {
            if ([userView.userId isEqualToString:linker.user.user_id]) {
                [userView removeFromSuperview];
            }
        }
    }
}

- (void)onReceivedPuChatMsg:(PubChatModel *)msg message:(QNIMMessageObject *)message {
    [self.chatRoomView showMessage:message];
}

//接受到连麦邀请
- (void)onReceiveLinkInvitation:(QNInvitationModel *)model {
    NSString *title = [model.invitation.msg.initiator.nick stringByAppendingString:@"申请加入连麦，是否同意？"];
    [QNAlertViewController showBaseAlertWithTitle:title content:@"" handler:^(UIAlertAction * _Nonnull action) {
        [self.chatService sendLinkMicAccept:model.invitation.msg.initiator.user_id];
    }];
}

//接收到pk邀请
- (void)onReceivePKInvitation:(QNInvitationModel *)model {
    NSString *title = [model.invitation.msg.initiator.nick stringByAppendingString:@"邀请您PK，是否同意？"];
    [QNAlertViewController showBaseAlertWithTitle:title content:@"" handler:^(UIAlertAction * _Nonnull action) {
        
        [self.chatService sendPKAccept:model.invitation.msg.initiatorRoomId receiveUserId:model.invitation.msg.initiator.user_id receiverIMId:model.invitation.msg.initiator.im_userid];
    }];
}

//收到同意pk邀请
- (void)onReceivePKInvitationAccept:(QNInvitationModel *)model {
    
    __weak typeof(self)weakSelf = self;

    [self.pkService startWithReceiverRoomId:model.invitation.msg.initiatorRoomId receiverUid:model.invitation.msg.initiator.user_id extensions:@"" callBack:^(QNPKSession * _Nonnull pkSession) {
        [weakSelf.chatService sendStartPKMessageWithReceiverId:weakSelf.selectPkRoomInfo.anchor_info.user_id receiveRoomId:weakSelf.selectPkRoomInfo.live_id receiverIMId:weakSelf.selectPkRoomInfo.anchor_info.im_userid relayId:pkSession.relay_id relayToken:pkSession.relay_token];
        
        [self.pushClient joinLive:pkSession.relay_token];
    }];
    
}

//收到开始pk信令
- (void)onReceiveStartPKSession:(QNPKSession *)pkSession {
    [self.pushClient joinLive:pkSession.relay_token];
}

//自己是否是房主
- (BOOL)isAdmin {
    BOOL isAdmin = NO;
    if ([self.roomInfo.anchor_info.user_id isEqualToString:QN_User_id]) {
        isAdmin = YES;
    }
    return isAdmin;
}

#pragma mark ---------QNRoomLifeCycleListener

//加入房间回调
- (void)onRoomJoined:(QNLiveRoomInfo *)roomInfo {
    [self.pushClient joinLive:roomInfo.room_token];    
    [self.pushClient beginMixStream:self.option];
}

- (RoomHostSlot *)roomHostSlot {
    if (!_roomHostSlot) {
        _roomHostSlot = [[RoomHostSlot alloc]init];
        [_roomHostSlot createDefaultView:CGRectMake(20, 60, 135, 40) onView:self.view];
        [_roomHostSlot updateWith:self.roomInfo];;
        _roomHostSlot.clickBlock = ^{
            NSLog(@"点击了房主头像");
        };
    }
    return _roomHostSlot;
}

- (OnlineUserSlot *)onlineUserSlot {
    if (!_onlineUserSlot) {
        _onlineUserSlot = [[OnlineUserSlot alloc]init];
        [_onlineUserSlot createDefaultView:CGRectMake(self.view.frame.size.width - 60, 60, 40, 40) onView:self.view];
        [_onlineUserSlot updateWith:self.roomInfo];
        _onlineUserSlot.clickBlock = ^{
            NSLog(@"点击了在线人数");
        };
    }
    return _onlineUserSlot;
}



- (BottomMenuSlot *)bottomMenuSlot {
    if (!_bottomMenuSlot) {
        NSMutableArray *slotList = [NSMutableArray array];
        __weak typeof(self)weakSelf = self;
        ItemSlot *pubchat = [[ItemSlot alloc]init];
        [pubchat normalImage:@"pub_chat" selectImage:@"pub_chat"];
        
        pubchat.clickBlock = ^{
            [weakSelf.chatRoomView commentBtnPressed];
            NSLog(@"点击了公聊");
        };
        [slotList addObject:pubchat];
        
        ItemSlot *pk = [[ItemSlot alloc]init];
        [pk normalImage:@"pk" selectImage:@"end_pk"];
        pk.clickBlock = ^{
            NSLog(@"点击了pk");
            
            [QNLiveRoomEngine listRoomWithPageNumber:1 pageSize:20 callBack:^(NSArray<QNLiveRoomInfo *> * _Nonnull list) {
                
                [weakSelf popInvitationPKView:list];
                
            }];
            
        };
        [slotList addObject:pk];
        
        ItemSlot *link = [[ItemSlot alloc]init];
        [link normalImage:@"link" selectImage:@"link"];
        link.clickBlock = ^{
            NSLog(@"点击了连麦");
        };
        [slotList addObject:link];
        
        ItemSlot *message = [[ItemSlot alloc]init];
        [message normalImage:@"message" selectImage:@"message"];
        message.clickBlock = ^{
            NSLog(@"点击了私信");
        };
        [slotList addObject:message];
        
        ItemSlot *close = [[ItemSlot alloc]init];
        [close normalImage:@"live_close" selectImage:@"live_close"];
        close.clickBlock = ^{
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            NSLog(@"点击了关闭");
        };
        [slotList addObject:close];
        
        _bottomMenuSlot = [[BottomMenuSlot alloc]init];
        _bottomMenuSlot.slotList = slotList.copy;
        [_bottomMenuSlot createDefaultView:CGRectMake(0, SCREEN_H - 80, SCREEN_W, 45) onView:self.view];
           
    }
    return _bottomMenuSlot;
}

- (void)popInvitationPKView:(NSArray<QNLiveRoomInfo *> *)list {
    
    QNInvitationMemberListController *vc = [[QNInvitationMemberListController alloc] initWithList:list];
    __weak typeof(self)weakSelf = self;
    vc.invitationClickedBlock = ^(QNLiveRoomInfo * _Nonnull itemModel) {
       
        [weakSelf.chatService sendPKInvitation:itemModel.live_id receiveUserId:itemModel.anchor_info.user_id receiverIMId:itemModel.anchor_info.im_userid];
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
