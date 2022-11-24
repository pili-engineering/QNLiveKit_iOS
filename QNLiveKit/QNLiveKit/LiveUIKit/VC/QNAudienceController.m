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
#import "QNGiftModel.h"
#import "QNPayGiftViewController.h"
#import "QNGiftMessagePannel.h"
#import "QNGiftPaySuccessView.h"
#import "QNLikeMenuView.h"

@interface QNAudienceController ()<QNChatRoomServiceListener,QNPushClientListener,LiveChatRoomViewDelegate,FDanmakuViewProtocol,PLPlayerDelegate,MicLinkerListener,PKServiceListener,GiftViewDelegate>
@property (nonatomic,strong)UILabel *masterLeaveLabel;
@property (nonatomic, strong) QNGiftView *giftView;
@property (nonatomic, strong) QNGiftPaySuccessView *paySuccessView;
@end

@implementation QNAudienceController

- (void)viewWillAppear:(BOOL)animated {
    self.preview.frame = CGRectZero;
    self.player.mute = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBottomMenuView];
    
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

// 收到喜欢消息
- (void)onReceivedLikeMsg:(QNIMMessageObject *)msg {
    
}

// 收到礼物消息
- (void)onreceivedGiftMsg:(QNIMMessageObject *)msg {
    [self.chatRoomView showMessage:msg];
    [self.giftMessagePannel showGiftMessage:msg];
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

- (void)setupBottomMenuView {
    
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
 
    QNLikeMenuView *likeView = [[QNLikeMenuView alloc] initWithFrame:CGRectZero];
    [likeView bundleNormalImage:@"like_click" selectImage:@"like_click"];
    likeView.roomInfo = self.roomInfo;
    [slotList addObject:likeView];
 
    //更多
    ImageButtonView *more = [[ImageButtonView alloc]initWithFrame:CGRectZero];
    [more bundleNormalImage:@"icon_more" selectImage:@"icon_more"];
    more.clickBlock = ^(BOOL selected) {
        [weakSelf popMoreView];
    };
    [slotList addObject:more];
    

        
    [self.bottomMenuView updateWithSlotList:slotList.copy];
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
- (void)giftViewSendGiftInView:(QNGiftView *)giftView data:(QNGiftModel *)model {
    if (model.amount == 0) {
        [self showPayAmountView:model];
    } else {
        [self requestSendGift:model amount:0];
    }
}

- (void)showPayAmountView:(QNGiftModel *)model {
    __weak typeof(self) weakSelf = self;
    QNPayGiftViewController *payVC = [[QNPayGiftViewController alloc] initWithComplete:^(NSInteger amount){
        if (amount == 0) {
            return;
        }
        
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf requestSendGift:model amount:amount];
    }];
    [self presentViewController:payVC animated:YES completion:^{
    }];
}

- (void)requestSendGift:(QNGiftModel *)model amount:(NSInteger)amount{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"live_id"] = self.roomInfo.live_id;
    dic[@"gift_id"] = @(model.gift_id);
    if (model.amount > 0) {
        dic[@"amount"] = @(model.amount);
    } else {
        dic[@"amount"] = @(amount);
    }

    [QLiveNetworkUtil postRequestWithAction:@"client/gift/send" params:dic  success:^(NSDictionary * _Nonnull responseData) {
        NSLog(@"success %@", responseData);
        [self showPaySuccessView];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"gift send error %@", error);
        [QToastView showToast:@"支付失败"];
    }];
}

- (void)showPaySuccessView {
    [self.view addSubview:self.paySuccessView];
    [self.paySuccessView setHidden:NO];
    
    [self performSelector:@selector(hidePaySuccessView) withObject:nil afterDelay:0.5];
}

- (void)hidePaySuccessView {
    [self.paySuccessView setHidden:YES];
    [self.paySuccessView removeFromSuperview];
}

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


- (void)closeViewController {
    [super closeViewController];
}

- (QNGiftPaySuccessView *) paySuccessView {
    if (!_paySuccessView) {
        CGFloat x = (SCREEN_W - 136) / 2.0;
        _paySuccessView = [[QNGiftPaySuccessView alloc] initWithFrame:CGRectMake(x, 240, 136, 130)];
    }
    return _paySuccessView;
}
@end
