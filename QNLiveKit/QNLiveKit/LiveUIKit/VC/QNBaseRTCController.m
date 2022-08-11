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
        _chatRoomView = [[LiveChatRoom alloc] initWithFrame:CGRectMake(0, SCREEN_H - 245, 260, 280)];
        _chatRoomView.groupId = self.roomInfo.chat_id;
        [self.view addSubview:_chatRoomView];
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

- (FDanmakuView *)danmakuView {
    if (!_danmakuView) {
        _danmakuView = [[FDanmakuView alloc]initWithFrame:CGRectMake(0, 180, SCREEN_W, 200)];
        _danmakuView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_danmakuView];
    }
    return _danmakuView;
}


@end
