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
@property (nonatomic, strong) QNLiveRoomInfo *selectPkRoomInfo;
@property (nonatomic, strong) QNPKSession *pkSession;//正在进行的pk
@end

@implementation QNLiveController

- (void)viewDidDisappear:(BOOL)animated {
    [self.roomClient closeRoom:^{
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self)weakSelf = self;
    [self.roomClient addRoomLifeCycleListener:self];
    [self.pushClient addPushClientListener:self];
    [self.chatService addChatServiceListener:self];
    [self.roomClient startLive:^(QNLiveRoomInfo * _Nonnull roomInfo) {
        self.roomInfo = roomInfo;
        [self updateRoomInfo];
    }];
    
    [self chatRoomView];
    [self roomHostSlot];
    [self onlineUserSlot];
    [self bottomMenuSlot];
    
    [self.chatService sendWelComeMsg:^(QNIMMessageObject * _Nonnull msg) {
        [weakSelf.chatRoomView showMessage:msg];
    }];
}

- (void)updateRoomInfo {
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.roomClient roomHeartBeart];
        [weakSelf.roomClient getRoomInfo:^(QNLiveRoomInfo * _Nonnull roomInfo) {
            weakSelf.roomInfo = roomInfo;
            [weakSelf.roomHostSlot updateWith:roomInfo];
            [weakSelf.onlineUserSlot updateWith:roomInfo];
        }];
    });
}

#pragma mark ---------QNPushClientListener
//房间连接状态
- (void)onConnectionRoomStateChanged:(QNConnectionState)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (state == QNConnectionStateConnected) {
            [self.pushClient beginMixStream:self.option];
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
                QNRemoteVideoTrack *videoTrack = (QNRemoteVideoTrack *)track;
                RemoteUserVIew *remoteView = [[RemoteUserVIew alloc]initWithFrame:CGRectMake(SCREEN_W - 120, 120, 100, 100)];
                remoteView.userId = userID;
                remoteView.trackId = videoTrack.trackID;
                [self.renderBackgroundView addSubview:remoteView];
                [videoTrack play:remoteView];
                
                if (self.pkSession) {
                    
                    self.preview.frame = CGRectMake(0, 130, SCREEN_W/2, SCREEN_W/1.5);
                    remoteView.frame = CGRectMake(SCREEN_W/2, 130, SCREEN_W/2, SCREEN_W/1.5);
                    [self.pkService PKStartedWithRelayID:self.pkSession.relay_id];
                                        
                    CameraMergeOption *selfOption = [CameraMergeOption new];
                    selfOption.frame = CGRectMake(0, 0, 720/2, 419);
                    selfOption.mZ = 0;
                    [self.pushClient updateUserVideoMergeOptions:QN_User_id trackId:self.pushClient.localVideoTrack.trackID option:selfOption];
                    
                    CameraMergeOption *userOption = [CameraMergeOption new];
                    userOption.frame = CGRectMake(720/2, 0, 720/2, 419);
                    userOption.mZ = 1;
                    [self.pushClient updateUserVideoMergeOptions:userID trackId:videoTrack.trackID option:userOption];
                }
            } else {
                [self.pushClient updateUserAudioMergeOptions:userID trackId:track.trackID isNeed:YES];
            }
            
        }
    });
}

//- (void)didSubscribedRemoteVideoTracks:(NSArray<QNRemoteVideoTrack *> *)videoTracks audioTracks:(NSArray<QNRemoteAudioTrack *> *)audioTracks ofUserID:(NSString *)userID {
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        for (QNRemoteVideoTrack *videoTrack in videoTracks) {
//            RemoteUserVIew *remoteView = [[RemoteUserVIew alloc]initWithFrame:CGRectMake(SCREEN_W - 120, 120, 100, 100)];
//            remoteView.userId = userID;
//            remoteView.trackId = videoTrack.trackID;
//            [self.renderBackgroundView addSubview:remoteView];
//            [videoTrack play:remoteView];
//
//            if (self.pkSession) {
//
//                self.preview.frame = CGRectMake(0, 130, SCREEN_W/2, SCREEN_W/1.5);
//                remoteView.frame = CGRectMake(SCREEN_W/2, 130, SCREEN_W/2, SCREEN_W/1.5);
//                [self.pkService PKStartedWithRelayID:self.pkSession.relay_id];
//
//                CameraMergeOption *selfOption = [CameraMergeOption new];
//                selfOption.frame = CGRectMake(0, 0, 720/2, 419);
//                selfOption.mZ = 0;
//                [self.pushClient updateUserVideoMergeOptions:QN_User_id trackId:self.pushClient.localVideoTrack.trackID option:selfOption];
//
//                CameraMergeOption *userOption = [CameraMergeOption new];
//                userOption.frame = CGRectMake(720/2, 0, 720/2, 419);
//                userOption.mZ = 1;
//                [self.pushClient updateUserVideoMergeOptions:userID trackId:videoTrack.trackID option:userOption];
//            }
//        }
//
//        for (QNRemoteAudioTrack *audioTrack in audioTracks) {
//            [self.pushClient updateUserAudioMergeOptions:userID trackId:audioTrack.trackID isNeed:YES];
//        }
//
//
//    });
//}

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
    
    [self.pkService startWithReceiverRoomId:model.invitation.msg.initiatorRoomId receiverUid:model.invitation.msg.initiator.user_id extensions:@"" callBack:^(QNPKSession * _Nonnull pkSession) {
        
        [self.chatService sendStartPKMessageWithReceiverId:self.selectPkRoomInfo.anchor_info.user_id receiveRoomId:self.selectPkRoomInfo.live_id receiverIMId:self.selectPkRoomInfo.anchor_info.im_userid relayId:pkSession.relay_id relayToken:pkSession.relay_token];
        
        [self beginPK:pkSession];
    }];
    
}

//收到开始pk信令
- (void)onReceiveStartPKSession:(QNPKSession *)pkSession {
    
    [self.pkService getPKToken:pkSession.relay_id callBack:^(QNPKSession * session) {
        [self beginPK:session];
    }];
    
}

- (void)onReceiveStopPKSession:(QNPKSession *)pkSession {
    
    [self stopPK];
    
}

- (void)beginPK:(QNPKSession *)pkSession {
    
    self.pkSession = pkSession;
    
    [self.pushClient stopMixStream];
    [self.pushClient unpublish:@[self.pushClient.localVideoTrack,self.pushClient.localAudioTrack]];
    [self.pushClient joinLive:pkSession.relay_token];
}

- (void)stopPK {
    
    [self.pkService stopWithRelayID:self.pkSession.relay_id callBack:^{
        [self.pushClient stopMixStream];
        [self.pushClient unpublish:@[self.pushClient.localAudioTrack,self.pushClient.localVideoTrack]];
        [self.pushClient joinLive:self.roomInfo.live_id];
    }];
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
    
}

- (RoomHostSlot *)roomHostSlot {
    if (!_roomHostSlot) {
        _roomHostSlot = [[RoomHostSlot alloc]init];
        [_roomHostSlot createDefaultView:CGRectMake(20, 60, 135, 40) onView:self.view];
        [_roomHostSlot updateWith:self.roomInfo];;
        _roomHostSlot.clickBlock = ^(BOOL selected) {
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
        _onlineUserSlot.clickBlock = ^(BOOL selected){
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
        
        pubchat.clickBlock = ^(BOOL selected){
            [weakSelf.chatRoomView commentBtnPressed];
            NSLog(@"点击了公聊");
        };
        [slotList addObject:pubchat];
        
        ItemSlot *pk = [[ItemSlot alloc]init];
        [pk normalImage:@"pk" selectImage:@"end_pk"];
        pk.clickBlock = ^(BOOL selected){
            NSLog(@"点击了pk");
            if (selected) {
                [QNLiveRoomEngine listRoomWithPageNumber:1 pageSize:20 callBack:^(NSArray<QNLiveRoomInfo *> * _Nonnull list) {
                    [weakSelf popInvitationPKView:list];
                }];
            } else {
                [weakSelf.chatService sendStopPKMessageWithReceiverId:self.pkSession.receiver.user_id receiveRoomId:self.pkSession.receiverRoomId receiverIMId:self.pkSession.receiver.im_userid relayId:self.pkSession.relay_id relayToken:self.pkSession.relay_token];
                [weakSelf stopPK];
            }
        };
        [slotList addObject:pk];
        
        ItemSlot *link = [[ItemSlot alloc]init];
        [link normalImage:@"link" selectImage:@"link"];
        link.clickBlock = ^(BOOL selected){
            NSLog(@"点击了连麦");
        };
        [slotList addObject:link];
        
        ItemSlot *message = [[ItemSlot alloc]init];
        [message normalImage:@"message" selectImage:@"message"];
        message.clickBlock = ^(BOOL selected){
            NSLog(@"点击了私信");
        };
        [slotList addObject:message];
        
        ItemSlot *close = [[ItemSlot alloc]init];
        [close normalImage:@"live_close" selectImage:@"live_close"];
        close.clickBlock = ^(BOOL selected){
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
