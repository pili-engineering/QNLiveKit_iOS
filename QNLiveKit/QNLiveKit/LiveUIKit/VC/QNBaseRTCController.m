//
//  QNBaseRTCController.m
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/30.
//

#import "QNBaseRTCController.h"
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
#import "QPKService.h"
#import "QRenderView.h"
#import "FDanmakuView.h"
#import "QStatisticalService.h"
#import "QNGiftMessagePannel.h"

@interface QNBaseRTCController ()

@end

@implementation QNBaseRTCController

- (void)viewDidDisappear:(BOOL)animated {
    [self.chatService removeChatServiceListener];
    [[QLive createPlayerClient] leaveRoom:self.roomInfo.live_id];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBG];
    
    [self.view addSubview:self.chatRoomView];
    [self.view addSubview:self.roomHostView];
    [self.view addSubview:self.onlineUserView];
    [self.view addSubview:self.pubchatView];
    [self.view addSubview:self.bottomMenuView];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.giftMessagePannel];
}

- (void)setupBG {
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"live_bg"]];
    bg.frame = self.view.frame;
    [self.view addSubview:bg];
    
    self.renderBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H)];
    self.renderBackgroundView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:self.renderBackgroundView atIndex:1];
        
    [self.renderBackgroundView addSubview:self.preview];
    [self.renderBackgroundView addSubview:self.remoteView];
}

//获取某人的画面
- (QRenderView *)getUserView:(NSString *)uid {
    
    for (QRenderView *userView in self.renderBackgroundView.subviews) {
        if ([userView.userId isEqualToString:uid]) {
            return userView;
        }
    }    
    return nil;

}

//移除所有远端view
- (void)removeRemoteUserView {
    [self.renderBackgroundView.subviews enumerateObjectsUsingBlock:^(__kindof QRenderView * _Nonnull userView, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![userView.userId isEqualToString:LIVE_User_id]) {
            [userView removeFromSuperview];
        }
    }];
}

- (QRenderView *)preview {
    if (!_preview) {
        _preview = [[QRenderView alloc] init];
        _preview.userId= LIVE_User_id;
        _preview.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
        _preview.fillMode = QNVideoFillModePreserveAspectRatioAndFill;
    }
    return _preview;
}

- (QRenderView *)remoteView {
    if (!_remoteView) {
        _remoteView = [[QRenderView alloc]initWithFrame:CGRectZero];
        _remoteView.fillMode = QNVideoFillModePreserveAspectRatioAndFill;
    }
    return _remoteView;
}

- (LiveChatRoom *)chatRoomView {
    if (!_chatRoomView) {
        _chatRoomView = [[LiveChatRoom alloc] initWithFrame:CGRectMake(8, SCREEN_H - 315, 238, 280)];
        _chatRoomView.groupId = self.roomInfo.chat_id;
    }
    return _chatRoomView;
}

- (QNChatRoomService *)chatService {
    if (!_chatService) {
        _chatService = [[QNChatRoomService alloc] init];
        _chatService.roomInfo = self.roomInfo;
    }
    return _chatService;
}

- (QPKService *)pkService {
    if (!_pkService) {
        _pkService = [[QPKService alloc]init];
        _pkService.roomInfo = self.roomInfo;
    }
    return _pkService;
}

- (QLinkMicService *)linkService {
    if (!_linkService) {
        _linkService = [[QLinkMicService alloc] init];
        _linkService.roomInfo = self.roomInfo;
    }
    return _linkService;
}

- (QStatisticalService *)statisticalService {
    if (!_statisticalService) {
        _statisticalService = [[QStatisticalService alloc]init];
        _statisticalService.roomInfo = self.roomInfo;
    }
    return _statisticalService;
}

- (FDanmakuView *)danmakuView {
    if (!_danmakuView) {
        _danmakuView = [[FDanmakuView alloc]initWithFrame:CGRectMake(0, 180, SCREEN_W, 200)];
        _danmakuView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_danmakuView];
    }
    return _danmakuView;
}


- (void)closeViewController {
    if ([QLive createPusherClient].rtcClient.connectionState == QNConnectionStateConnected) {
        [[QLive createPusherClient].rtcClient leave];
        [[QLive createPlayerClient] leaveRoom:self.roomInfo.live_id];
        [self.linkService downMic];
    }
    
    [self.chatService sendLeaveMsg];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SubViews
- (RoomHostView *)roomHostView {
    if (!_roomHostView) {
        _roomHostView = [[RoomHostView alloc]initWithFrame:CGRectMake(20, 60, 135, 40)];
        [_roomHostView updateWith:self.roomInfo];;
        _roomHostView.clickBlock = ^(BOOL selected){
            NSLog(@"点击了房主头像");
        };
    }
    return _roomHostView;
}

- (OnlineUserView *)onlineUserView {
    if (!_onlineUserView) {
        _onlineUserView = [[OnlineUserView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 190, 60, 150, 60)];
        [_onlineUserView updateWith:self.roomInfo];
        _onlineUserView.clickBlock = ^(BOOL selected){
            NSLog(@"点击了在线人数");
        };
    }
    return _onlineUserView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_W - 40, 70, 20, 20)];
        [_closeButton setImage:[UIImage imageNamed:@"icon_quit"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeViewController) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (ImageButtonView *)pubchatView {
    if (!_pubchatView) {
        _pubchatView = [[ImageButtonView alloc]initWithFrame:CGRectMake(15, SCREEN_H - 52.5, 170, 30)];
        _pubchatView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        _pubchatView.layer.cornerRadius = 15;
        _pubchatView.clipsToBounds = YES;
        
        
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"pub_chat"]];
        imageView.frame = CGRectMake(10, 7, 16, 16);
        [_pubchatView addSubview:imageView];
        
        __weak typeof(self)weakSelf = self;
        _pubchatView.clickBlock = ^(BOOL selected){
            [weakSelf.chatRoomView commentBtnPressedWithPubchat:YES];
        };
        
    }
    return _pubchatView;
}

- (BottomMenuView *)bottomMenuView {
    if (!_bottomMenuView) {
        _bottomMenuView = [[BottomMenuView alloc]initWithFrame:CGRectMake(200, SCREEN_H - 60, SCREEN_W - 200, 45)];
    }
    return _bottomMenuView;
}

- (QNGiftMessagePannel *)giftMessagePannel {
    if (!_giftMessagePannel) {
        _giftMessagePannel = [[QNGiftMessagePannel alloc] initWithFrame:CGRectMake(8, SCREEN_H - 315 - 150, 170, 150)];
    }
    return _giftMessagePannel;
}
@end
