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
@property (nonatomic, strong) QNLiveRoomClient *roomClient;
@property (nonatomic, strong) RoomHostSlot *roomHostSlot;
@property (nonatomic, strong) OnlineUserSlot *onlineUserSlot;
@property (nonatomic, strong) BottomMenuSlot *bottomMenuSlot;
@end

@implementation QNLiveController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self)weakSelf = self;
    [self.roomClient startLive:^(QNLiveRoomInfo * _Nonnull roomInfo) {
        weakSelf.roomInfo = roomInfo;
    }];
    
    [self roomHostSlot];
    [self onlineUserSlot];
    [self bottomMenuSlot];
    
}

#pragma mark ---------QNPushClientListener
//直播推流连接状态
- (void)onConnectionStateChanged:(QNConnectionState)state {
    if (state == QNConnectionStateConnected) {
        [self.pushClient setLocalPreView:self.preview];
        [self.pushClient publishCameraAndMicrophone:^(BOOL onPublished, NSError * _Nonnull error) {
                    
        }];
    }
}

#pragma mark ---------QNRoomLifeCycleListener

//加入房间回调
- (void)onRoomJoined:(QNLiveRoomInfo *)roomInfo {
    [self.pushClient joinLive];
}

- (QNLivePushClient *)pushClient {
    if (!_pushClient) {
        _pushClient = [[QNLivePushClient alloc]initWithToken:self.roomInfo.room_token];
        [_pushClient addPushClientListener:self];
        
    }
    return _pushClient;
}

- (QNLiveRoomClient *)roomClient {
    if (!_roomClient) {
        _roomClient = [[QNLiveRoomClient alloc]initWithLiveId:self.roomInfo.live_id];
        [_roomClient addRoomLifeCycleListener:self];
    }
    return _roomClient;
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
            NSLog(@"点击了公聊");
        };
        [slotList addObject:pubchat];
        
        ItemSlot *pk = [[ItemSlot alloc]init];
        [pk normalImage:@"pk" selectImage:@"end_pk"];
        pk.clickBlock = ^{
            NSLog(@"点击了pk");
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

@end
