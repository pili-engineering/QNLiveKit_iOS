//
//  QNLiveController.m
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/30.
//

#import "QNLiveController.h"
#import <QNLiveKit/QNLiveKit.h>

@interface QNLiveController ()<QNPushClientListener,QNRoomLifeCycleListener>
@property (nonatomic, strong) QNLivePushClient *pushClient;
@end

@implementation QNLiveController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.pushClient startLive:self.roomInfo.live_id callBack:^{}];
}

#pragma mark ---------QNPushClientListener
//直播推流连接状态
- (void)onConnectionStateChanged:(QNConnectionState)state {
    if (state == QNConnectionStateConnected) {
        [self.pushClient publishCameraAndMicrophone:^(BOOL onPublished, NSError * _Nonnull error) {
                    
        }];
    }
}

#pragma mark ---------QNRoomLifeCycleListener

//进入房间回调
- (void)onRoomEnter:(QNLiveUser *)user{
    __weak typeof(self)weakSelf = self;
    [self.pushClient joinRoom:self.roomInfo.live_id callBack:^(QNLiveRoomInfo * _Nonnull roomInfo) {
        weakSelf.roomInfo = roomInfo;
    }];
}

//加入房间回调
- (void)onRoomJoined:(QNLiveRoomInfo *)roomInfo {
    [self.pushClient joinLive:roomInfo.room_token];
}

- (QNLivePushClient *)pushClient {
    if (!_pushClient) {
        _pushClient = [QNLivePushClient createLivePushClient];
        [_pushClient setPushClientListener:self];
        [_pushClient addRoomLifeCycleListener:self];
    }
    return _pushClient;
}

@end
