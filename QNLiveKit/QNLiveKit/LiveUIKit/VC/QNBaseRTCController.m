//
//  QNBaseRTCController.m
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/30.
//

#import "QNBaseRTCController.h"
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
#import "QNPKService.h"
#import "QRenderView.h"

@interface QNBaseRTCController ()

@end

@implementation QNBaseRTCController

- (void)viewWillDisappear:(BOOL)animated {

    self.chatService = nil;
    self.pkService = nil;
    self.linkService = nil;
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
    [self.view insertSubview:self.renderBackgroundView atIndex:1];
    
    self.preview = [[QRenderView alloc] init];
    self.preview.userId= QN_User_id;
    self.preview.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
    [self.renderBackgroundView addSubview:self.preview];
}

- (void)removeUserViewWithUid:(NSString *)uid {
    [self.renderBackgroundView.subviews enumerateObjectsUsingBlock:^(__kindof QRenderView * _Nonnull userView, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([userView.userId isEqualToString:uid]) {
            [userView removeFromSuperview];
        }
    }];
}

//移除所有远端view
- (void)removeRemoteUserView {
    [self.renderBackgroundView.subviews enumerateObjectsUsingBlock:^(__kindof QRenderView * _Nonnull userView, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![userView.userId isEqualToString:QN_User_id]) {
            [userView removeFromSuperview];
        }
    }];
}

- (QNLinkMicService *)linkService {
    if (!_linkService) {
        _linkService = [[QNLinkMicService alloc] initWithLiveId:self.roomInfo.live_id];
    }
    return _linkService;
}

- (LiveChatRoom *)chatRoomView {
    if (!_chatRoomView) {
        _chatRoomView = [[LiveChatRoom alloc] initWithFrame:CGRectMake(0, SCREEN_H - 320  - [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom, SCREEN_W, 320)];
        _chatRoomView.groupId = self.roomInfo.chat_id;
        [self.view addSubview:_chatRoomView];
    }
    return _chatRoomView;
}

- (QNChatRoomService *)chatService {
    if (!_chatService) {
        _chatService = [[QNChatRoomService alloc]initWithGroupId:self.roomInfo.chat_id roomId:self.roomInfo.live_id];
    }
    return _chatService;
}

- (QNPKService *)pkService {
    if (!_pkService) {
        _pkService = [[QNPKService alloc]initWithRoomId:self.roomInfo.live_id];
    }
    return _pkService;
}

- (QNMergeOption *)option {
    if (!_option) {
        _option = [QNMergeOption new];
        _option.width = 720;
        _option.height = 1280;
//        QNTranscodingLiveStreamingImage *bgInfo = [[QNTranscodingLiveStreamingImage alloc] init];
//        bgInfo.frame = CGRectMake(0, 0, 720, 1280);
//        bgInfo.imageUrl = @"http://qrnlrydxa.hn-bkt.clouddn.com/am_room_bg.png";
//        _option.backgroundInfo = bgInfo;
    }
    return _option;
}

@end
