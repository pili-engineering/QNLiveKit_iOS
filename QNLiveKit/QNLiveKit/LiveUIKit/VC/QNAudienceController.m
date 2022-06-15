//
//  QNAudienceController.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/6.
//

#import "QNAudienceController.h"
#import "RoomHostSlot.h"
#import "OnlineUserSlot.h"
#import "BottomMenuSlot.h"
#import "QNChatRoomService.h"
#import "LiveChatRoom.h"
#import "QNLiveRoomInfo.h"
#import "QNLiveRoomClient.h"
#import <PLPlayerKit/PLPlayerKit.h>
#import "LinkStateSlot.h"
#import "QRenderView.h"


@interface QNAudienceController ()<QNChatRoomServiceListener,QNPushClientListener,
PLPlayerDelegate
>

@property (nonatomic, strong) RoomHostSlot *roomHostSlot;
@property (nonatomic, strong) OnlineUserSlot *onlineUserSlot;
@property (nonatomic, strong) BottomMenuSlot *bottomMenuSlot;
@property (nonatomic, strong) LinkStateSlot *linkSLot;
@property (nonatomic, strong) UIView *playView;
@end

@implementation QNAudienceController

- (void)viewDidDisappear:(BOOL)animated {
    [[QLive createPlayerClient] leaveRoom:self.roomInfo.live_id callBack:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self)weakSelf = self;
    [self.chatService addChatServiceListener:self];
    
    [[QLive createPlayerClient] joinRoom:self.roomInfo.live_id callBack:^(QNLiveRoomInfo * _Nonnull roomInfo) {
        weakSelf.roomInfo = roomInfo;
        [[QLive createPlayerClient] play:self.playView];
        [weakSelf updateRoomInfo];
    }];
    
    [self chatRoomView];
    [self roomHostSlot];
    [self onlineUserSlot];
    [self bottomMenuSlot];
    [self chatService];
    
    [self.chatService sendWelComeMsg:^(QNIMMessageObject * _Nonnull msg) {
        [weakSelf.chatRoomView showMessage:msg];
    }];
    
}

- (void)updateRoomInfo {
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[QLive getRooms] getRoomInfo:weakSelf.roomInfo.live_id callBack:^(QNLiveRoomInfo * _Nonnull roomInfo) {
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
            self.preview.frame = CGRectMake(SCREEN_W - 120, 120, 100, 100);
            self.preview.layer.cornerRadius = 50;
            self.preview.clipsToBounds = YES;
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
- (void)onReceiveLinkInvitationAccept:(QNInvitationModel *)model {
    __weak typeof(self)weakSelf = self;
    [QLive createPusherClient].pushClientListener = self;
    [self.linkService onMic:YES camera:YES extends:@"" callBack:^(NSString * _Nonnull rtcToken) {
        [[QLive createPusherClient] joinLive:rtcToken];
        [[QLive createPusherClient] enableCamera:nil renderView:self.preview];
        [weakSelf.chatService sendOnMicMsg];
    }];
      
    [[QLive createPlayerClient] stopPlay];
    
}



- (RoomHostSlot *)roomHostSlot {
    if (!_roomHostSlot) {
        _roomHostSlot = [[RoomHostSlot alloc]init];
        [_roomHostSlot createDefaultView:CGRectMake(20, 60, 135, 40) onView:self.view];
        [_roomHostSlot updateWith:self.roomInfo];;
        _roomHostSlot.clickBlock = ^(BOOL selected){
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
        
        ItemSlot *link = [[ItemSlot alloc]init];
        [link normalImage:@"link" selectImage:@"link"];
        link.clickBlock = ^(BOOL selected){
            
            [weakSelf.chatService sendLinkMicInvitation:weakSelf.roomInfo.anchor_info.user_id];
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

- (void)popLinkSLot {
    _linkSLot = [[LinkStateSlot alloc]init];
    [_linkSLot createDefaultView:CGRectMake(0, SCREEN_H - 230, SCREEN_W, 230) onView:self.view];
    __weak typeof(self)weakSelf = self;
    _linkSLot.microphoneBlock = ^(BOOL mute) {
        [[QLive createPusherClient] muteMicrophone:mute];
    };
    _linkSLot.cameraBlock = ^(BOOL mute) {
        [[QLive createPusherClient] muteCamera:mute];
    };
    _linkSLot.clickBlock = ^(BOOL selected){
        [[QLive createPusherClient] LeaveLive];
        weakSelf.preview.frame = CGRectZero;
        for (QRenderView *userView in weakSelf.renderBackgroundView.subviews) {
            if ([userView.class isEqual:[QRenderView class]]) {
                [userView removeFromSuperview];
            }
        }
        [weakSelf.linkService downMicCallBack:^(QNMicLinker * _Nonnull mic) {
                    
        }];
        [weakSelf.chatService sendDownMicMsg];
        [[QLive createPlayerClient] play:weakSelf.playView];
        NSLog(@"点击了结束连麦");
    };
}

- (UIView *)playView {
    if (!_playView) {
        _playView = [[UIView alloc]initWithFrame:self.view.frame];
        [self.view insertSubview:_playView atIndex:2];
    }
    return _playView;
}

@end
