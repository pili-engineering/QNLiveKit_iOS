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
#import "ShopBuyListController.h"
#import "ExplainingGoodView.h"
#import "QLiveNetworkUtil.h"
#import "GoodsModel.h"
#import "WacthRecordController.h"
#import "WatchBottomMoreView.h"
#import "QNGiftView.h"
#import "QNSendGiftModel.h"
#import "QNGiftShowManager.h"
#import "QNGiftMsgModel.h"

@interface QNAudienceController ()<QNChatRoomServiceListener,QNPushClientListener,LiveChatRoomViewDelegate,FDanmakuViewProtocol,PLPlayerDelegate,MicLinkerListener,PKServiceListener,GiftViewDelegate>
@property (nonatomic,strong)UILabel *masterLeaveLabel;
@property(nonatomic,strong) QNGiftView *giftView;
@end

@implementation QNAudienceController

- (void)viewWillAppear:(BOOL)animated {
    self.preview.frame = CGRectZero;
    self.player.mute = NO;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    __weak typeof(self)weakSelf = self;
    [self.chatService addChatServiceListener:self];
    self.pkService.delegate = self;
    self.linkService.micLinkerListener = self;
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

//正在讲解的商品
- (void)getExplainGood {
    NSString *action = [NSString stringWithFormat:@"client/item/demonstrate/%@",self.roomInfo.live_id];
    [QLiveNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        
        GoodsModel *explainGood = [GoodsModel mj_objectWithKeyValues:responseData];
        if (explainGood) {
            self.goodView.hidden = NO;
            [self.goodView updateWithModel:explainGood];
        } else {
            self.goodView.hidden = YES;
        }
        
    } failure:^(NSError * _Nonnull error) {}];
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
    self.player.playerView.backgroundColor = [UIColor clearColor];
    self.player.delegate = self;
    self.player.delegateQueue = dispatch_get_main_queue();
    [self.player play];
}

- (void)player:(nonnull PLPlayer *)player stoppedWithError:(nullable NSError *)error {
    [self.player.playerView  removeFromSuperview];
    self.masterLeaveLabel.hidden = NO;
}

- (void)player:(nonnull PLPlayer *)player width:(int)width height:(int)height {
    self.masterLeaveLabel.hidden = YES;
    if (height > 500) {
        self.player.playerView.frame = self.view.frame;
    } else {
        self.player.playerView.frame = CGRectMake(0, 150, SCREEN_W, SCREEN_W *0.6);        
    }
}

- (void)stopPlay {
    [self.player.playerView  removeFromSuperview];
    [self.player stop];
}

- (void)updateRoomInfo {
    [[QLive createPusherClient] roomHeartBeart:self.roomInfo.live_id];
    [[QLive getRooms] getRoomInfo:self.roomInfo.live_id callBack:^(QNLiveRoomInfo * _Nonnull roomInfo) {
        self.roomInfo = roomInfo;
        [self.roomHostView updateWith:roomInfo];
        [self.onlineUserView updateWith:roomInfo];
        
        if (roomInfo.AnchorStatus == QNAnchorStatusLeave) {
            [self.player.playerView  removeFromSuperview];
            [self.player stop];            
            self.masterLeaveLabel.hidden = NO;
        } else {
            self.masterLeaveLabel.hidden = YES;
            if ([QLive createPusherClient].rtcClient.connectionState != QNConnectionStateConnected) {
                if (!self.player.playerView.superview) {
                    [self.view insertSubview:self.player.playerView atIndex:2];
                } else {
                    if (self.player.status != PLPlayerStatusPlaying) {
                        [self.player play];
                    }
                }
            }
            
//            if (self.roomInfo.pk_id.length == 0) {
//                self.player.playerView.frame = self.view.frame;
//            } else {
//                self.player.playerView.frame = CGRectMake(0, 150, SCREEN_W, SCREEN_W *0.6);
//            }
        }
    }];
    [self getExplainGood];
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
            self.preview.hidden = NO;
            [self.renderBackgroundView bringSubviewToFront:self.preview];
            [[QLive createPusherClient] enableCamera:nil renderView:self.preview];
            [self popLinkSLot];

        } else if (state == QNConnectionStateDisconnected) {
            [self endLinkToLive];
        }
    });
}

//有人离开rtc
- (void)onUserLeaveRTC:(NSString *)userID {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([userID isEqualToString:self.roomInfo.anchor_info.user_id]) {

            [self endLinkToLive];
            [QToastView showToast:@"主播已离线"];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    });
}

- (void)onUserPublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (QNRemoteTrack *track in tracks) {
            if (track.kind == QNTrackKindVideo) {
                
                self.remoteView.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
                self.remoteView.userId = userID;
                self.remoteView.trackId = track.trackID;
                self.remoteView.hidden = NO;
                [self.renderBackgroundView bringSubviewToFront:self.remoteView];
                [(QNRemoteVideoTrack *)track play:self.remoteView];
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
    
    if ([user.user_id isEqualToString:self.roomInfo.anchor_info.user_id]) {
        [QToastView showToast:@"直播间已关闭"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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

//收到有人被踢消息
- (void)onUserBeKick:(LinkOptionModel *)micLinker {
    if ([micLinker.uid isEqualToString:LIVE_User_id]) {
        self.preview.frame = CGRectZero;
        self.remoteView.frame = CGRectZero;
        [self playWithUrl:self.roomInfo.rtmp_url];
    }
}

//收到主播开始pk信令
- (void)onReceiveStartPKSession:(QNPKSession *)pkSession {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self replayPlayer];
     });
}

//收到主播结束pk信令
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

//消息已发送
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
    
    [self.statisticalService uploadComments];
}

- (UILabel *)masterLeaveLabel {
    if (!_masterLeaveLabel) {
        _masterLeaveLabel = [[UILabel alloc]init];
        _masterLeaveLabel.textColor = [UIColor whiteColor];
        _masterLeaveLabel.text = @"主播马上回来，敬请期待。";
        _masterLeaveLabel.textAlignment = NSTextAlignmentCenter;
        _masterLeaveLabel.font = [UIFont systemFontOfSize:14];
        _masterLeaveLabel.hidden = YES;
        [self.view addSubview:_masterLeaveLabel];
        [_masterLeaveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(300);
            make.centerX.equalTo(self.view);
        }];
    }
    return _masterLeaveLabel;
}

- (RoomHostView *)roomHostView {
    if (!_roomHostView) {
        _roomHostView = [[RoomHostView alloc]initWithFrame:CGRectMake(20, 60, 135, 40)];
        [self.view addSubview:_roomHostView];
        [_roomHostView updateWith:self.roomInfo];;
        _roomHostView.clickBlock = ^(BOOL selected){
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
        _pubchatView = [[ImageButtonView alloc]initWithFrame:CGRectMake(15, SCREEN_H - 52.5, 170, 30)];
        _pubchatView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        _pubchatView.layer.cornerRadius = 15;
        _pubchatView.clipsToBounds = YES;
        [self.view addSubview:_pubchatView];
        
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
        NSMutableArray *slotList = [NSMutableArray array];
        __weak typeof(self)weakSelf = self;
        
        //弹幕
        ImageButtonView *message = [[ImageButtonView alloc]initWithFrame:CGRectZero];
        [message bundleNormalImage:@"icon_danmu" selectImage:@"icon_danmu"];
        message.clickBlock = ^(BOOL selected){
            [weakSelf.chatRoomView commentBtnPressedWithPubchat:NO];
        };
        [slotList addObject:message];
        
        //购物车
        ImageButtonView *shopping = [[ImageButtonView alloc]initWithFrame:CGRectZero];
        [shopping bundleNormalImage:@"shopping" selectImage:@"shopping"];
        shopping.clickBlock = ^(BOOL selected){
            
            [weakSelf popGoodListView];
        };
        [slotList addObject:shopping];
        
        //更多
        ImageButtonView *more = [[ImageButtonView alloc]initWithFrame:CGRectZero];
        [more bundleNormalImage:@"icon_more" selectImage:@"icon_more"];
        more.clickBlock = ^(BOOL selected) {
            [weakSelf popMoreView];
                 };
        [slotList addObject:more];
        
        //关闭
        ImageButtonView *close = [[ImageButtonView alloc]initWithFrame:CGRectZero];
        [close bundleNormalImage:@"live_close" selectImage:@"live_close"];
        close.clickBlock = ^(BOOL selected){
            
            if ([QLive createPusherClient].rtcClient.connectionState == QNConnectionStateConnected) {
                [[QLive createPusherClient].rtcClient leave];
                [[QLive createPlayerClient] leaveRoom:weakSelf.roomInfo.live_id];
                [weakSelf.linkService downMic];
            }
            
            [weakSelf.chatService sendLeaveMsg];
            
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        };
        [slotList addObject:close];
        
        _bottomMenuView = [[BottomMenuView alloc]initWithFrame:CGRectMake(200, SCREEN_H - 60, SCREEN_W - 200, 45)];
        [_bottomMenuView updateWithSlotList:slotList.copy];
        [self.view addSubview:_bottomMenuView];

    }
    return _bottomMenuView;
}

- (void)popMoreView {
    __weak typeof(self)weakSelf = self;

    WatchBottomMoreView *moreView = [[WatchBottomMoreView alloc]initWithFrame:CGRectMake(0, SCREEN_H - 200, SCREEN_W, 200)];
    moreView.giftBlock = ^{
        
        [weakSelf.giftView showGiftView];
        
    };
    moreView.applyLinkBlock = ^ {
        [weakSelf.linkService ApplyLink:weakSelf.roomInfo.anchor_info];
        [QToastView showToast:@"连麦申请已发送"];
    };

    [self.view addSubview:moreView];
}

#pragma mark  --------GiftViewDelegate---------
//点击赠送礼物的回调
- (void)giftViewSendGiftInView:(QNGiftView *)giftView data:(QNSendGiftModel *)model {
        
    model.userIcon = LIVE_User_avatar;
    model.userName = LIVE_User_nickname;
    model.defaultCount = 0;
    model.sendCount = 1;

    [[QNGiftShowManager sharedManager] showGiftViewWithBackView:self.view info:model completeBlock:^(BOOL finished) {
        NSLog(@"赠送了礼物");
        
    }];
    [self requestSendGift:model];
    [self sendGiftMessage:model];
}

- (void)requestSendGift:(QNSendGiftModel *)model {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"live_id"] = self.roomInfo.live_id;
    dic[@"gift_id"] = model.gift_id;
    dic[@"amount"] = model.amount;

    [QLiveNetworkUtil postRequestWithAction:@"client/gift/send" params:dic success:^(NSDictionary * _Nonnull responseData) {

    } failure:^(NSError * _Nonnull error) {
        
    }];
}

//发送礼物信令和消息
-(void)sendGiftMessage:(QNSendGiftModel *)model {
    QNGiftModel *gift = [QNGiftModel new];
    gift.giftName = model.name;
    gift.giftId = model.gift_id;
    
#pragma warning -------发送礼物消息
    
}

//收到礼物信令的操作
//- (void)receivedGift:(GiftMsgModel *)model {
//    SendGiftModel *sendModel = [SendGiftModel new];
//    sendModel.userIcon = model.senderAvatar;
//    sendModel.userName = model.senderName;
//    sendModel.defaultCount = 0;
//    sendModel.sendCount = model.number;
//    sendModel.name = model.sendGift.name;
//    //通过礼物名字找到本地的礼物图
//    for (SendGiftModel *gift in self.giftView.dataArray) {
//        if ([model.sendGift.name isEqualToString:gift.name]) {
//            sendModel.img = gift.img;
//            sendModel.animation_img = gift.animation_img;
//        }
//    }
//    [[GiftShowManager sharedManager] showGiftViewWithBackView:self.view info:sendModel completeBlock:^(BOOL finished) {
//    }];
//}


- (void)popGoodListView {
        
        ShopBuyListController *vc = [[ShopBuyListController alloc] initWithLiveInfo:self.roomInfo];
        __weak typeof(self)weakSelf = self;
        vc.buyClickedBlock = ^(GoodsModel * _Nonnull itemModel) {
            if (weakSelf.goodClickedBlock) {
                weakSelf.goodClickedBlock(itemModel);
            }
            weakSelf.player.mute = YES;
        };
        vc.watchRecordBlock = ^(GoodsModel * _Nonnull itemModel) {
            weakSelf.player.mute = YES;
            
            WacthRecordController *vc = [[WacthRecordController alloc] initWithModel:itemModel roomInfo:weakSelf.roomInfo];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            vc.buyClickedBlock = ^(GoodsModel * _Nonnull itemModel) {
                if (self.goodClickedBlock) {
                    self.goodClickedBlock(itemModel);
                }
            };
            [weakSelf presentViewController:vc animated:YES completion:nil];
            
        };
        vc.view.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self addChildViewController:vc];
        [self.view addSubview:vc.view];
        
}

- (void)popLinkSLot {
    _linkSView = [[LinkStateView alloc]initWithFrame:CGRectMake(0, SCREEN_H - 230, SCREEN_W, 230)];
    [self.view addSubview:_linkSView];
    __weak typeof(self)weakSelf = self;
    _linkSView.microphoneBlock = ^(BOOL mute) {
        [[QLive createPusherClient] muteMicrophone:mute];
        
        [weakSelf.linkService updateMicStatusType:@"mic" flag:!mute];
        
    };
    _linkSView.cameraBlock = ^(BOOL mute) {
        [weakSelf.linkService updateMicStatusType:@"camera" flag:!mute];
    };
    _linkSView.clickBlock = ^(BOOL selected){
        [weakSelf endLinkToLive];
    };
}

//离开连麦，变为观看直播
- (void)endLinkToLive {
    [self.linkService downMic];
    self.preview.frame = CGRectZero;
    self.remoteView.frame = CGRectZero;
//    if (self.remoteView.superview && ![self.remoteView.userId isEqualToString:LIVE_User_id]) {
//        [self.remoteView removeFromSuperview];
//    }
    [self playWithUrl:self.roomInfo.rtmp_url];
    NSLog(@"结束连麦");
}

- (ExplainingGoodView *)goodView {
    if (!_goodView) {
        _goodView = [[ExplainingGoodView alloc]initWithFrame:CGRectMake(SCREEN_W - 130, SCREEN_H - 240, 115, 170)];
        __weak typeof(self)weakSelf = self;
        _goodView.buyClickedBlock = ^(GoodsModel * _Nonnull itemModel) {
            if (weakSelf.goodClickedBlock) {
                weakSelf.goodClickedBlock(itemModel);
            }
        };
        [self.view addSubview:_goodView];
    }
    return _goodView;
}

- (QNGiftView *)giftView{
    if (!_giftView) {
        _giftView = [[QNGiftView alloc] init];
        _giftView.delegate = self;
    }
    return _giftView;
}

- (QNLiveUser *)user {
    
    QNLiveUser *user = [QNLiveUser new];
    user.user_id = LIVE_User_id;
    user.nick = LIVE_User_nickname;
    user.avatar = LIVE_User_avatar;
    user.im_userid = LIVE_IM_userId;
    user.im_username = LIVE_IM_userName;
    return user;
}


@end
