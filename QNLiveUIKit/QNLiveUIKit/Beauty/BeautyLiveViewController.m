//
//  BeautyLiveViewController.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/30.
//

#import "BeautyLiveViewController.h"
#import "BottomMenuView.h"
#import "ExplainingGoodView.h"
#import "FDanmakuModel.h"
#import "FDanmakuView.h"
#import "LiveBottomMoreView.h"
#import "LiveChatRoom.h"
#import "OnlineUserView.h"
#import "QAlertView.h"
#import "QNGiftMessagePannel.h"
#import "QNLiveStatisticView.h"
#import "QNPKInvitationListController.h"
#import "QRenderView.h"
#import "QToastView.h"
#import "RoomHostView.h"
#import "ShopSellListController.h"
#import "UIViewController+QViewController.h"
#import <QNIMSDK/QNIMSDK.h>
#import <QNRTCKit/QNRTCKit.h>
#import "QNVoiceCollectionViewCell.h"
#import "ImageButtonView.h"

static NSString *cellIdentifier = @"AddCollectionViewCell";

@interface BeautyLiveViewController () <QNPushClientListener, QNRoomLifeCycleListener, QNPushClientListener, QNChatRoomServiceListener, FDanmakuViewProtocol, LiveChatRoomViewDelegate, MicLinkerListener, PKServiceListener, QNLocalVideoTrackDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) QNLiveRoomInfo *selectPkRoomInfo;
@property (nonatomic, strong) QNPKSession *pkSession;   // 正在进行的pk
@property (nonatomic, strong) QNLiveUser *pk_other_user;// pk对象
@property (nonatomic, strong) ImageButtonView *pkSlot;
@property (nonatomic, strong) LiveBottomMoreView *moreView;
@property (nonatomic, strong) QNLiveStatisticView *statisticView;

@property (nonatomic, strong) NSMutableArray<QNMicLinker *> *linkMicList;
@property (nonatomic, strong) UICollectionView *micLinkerCollectionView;
@property (nonatomic, strong) NSMutableDictionary<NSString *, QNTrack *> *currentTracks;

@end

@implementation BeautyLiveViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentTracks = [[NSMutableDictionary alloc] init];
    [self setupMicLinkerListView];

    [[QLive createPusherClient] setVideoFrameListener:self];
    [[QLive createPusherClient] enableCamera:nil renderView:self.preview];
    [QLive createPusherClient].pushClientListener = self;

    self.pkService.delegate = self;
    self.danmakuView.delegate = self;
    self.chatRoomView.delegate = self;
    [self.chatService addChatServiceListener:self];

    __weak typeof(self) weakSelf = self;
    [[QLive createPusherClient] startLive:self.roomInfo.live_id
                                 callBack:^(QNLiveRoomInfo *_Nonnull roomInfo) {
                                   weakSelf.roomInfo = roomInfo;
                                   [weakSelf updateRoomInfo];

                                   weakSelf.linkService.micLinkerListener = weakSelf;
                                   weakSelf.linkMicList = weakSelf.linkService.linkMicList;
                                 }];

    [self.view addSubview:self.roomHostView];
    [self.view addSubview:self.onlineUserView];
    [self.view addSubview:self.pubchatView];
    [self.view addSubview:self.bottomMenuView];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.giftMessagePannel];
    [self.view addSubview:self.statisticView];
    [self setupBottomMenuView];

    [self.chatService sendWelComeMsg:^(QNIMMessageObject *_Nonnull msg) {
      [weakSelf.chatRoomView showMessage:msg];
    }];
}

- (void)setupMicLinkerListView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 2;
    flowLayout.minimumInteritemSpacing = 2;
    flowLayout.itemSize = CGSizeMake(100, 100);
    self.micLinkerCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 400) collectionViewLayout:flowLayout];
    self.micLinkerCollectionView.backgroundColor = [UIColor clearColor];
    self.micLinkerCollectionView.delegate = self;
    self.micLinkerCollectionView.dataSource = self;
    //    self.audioCollectionView.scrollEnabled = NO;
    [self.micLinkerCollectionView registerClass:[QNVoiceCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.renderBackgroundView addSubview:_micLinkerCollectionView];
    [_micLinkerCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.mas_equalTo(self.view.mas_right).offset(-130);
      make.top.mas_equalTo(self.view.mas_top).mas_offset(120);
      make.size.mas_equalTo(CGSizeMake(110, 400));
    }];

    [self.renderBackgroundView addSubview:_micLinkerCollectionView];
}

- (void)updateRoomInfo {
    __weak typeof(self) weakSelf = self;
    [[QLive createPusherClient] startRoomHeartBeart:self.roomInfo.live_id callBack:^(QNLiveRoomInfo * _Nonnull roomInfo) {
        weakSelf.roomInfo = roomInfo;
        [weakSelf.roomHostView updateWith:roomInfo];
        [weakSelf.onlineUserView updateWith:roomInfo];
        [weakSelf.statisticView updateWith:roomInfo];
    }];
}

#pragma mark---------QNPushClientListener
// 房间连接状态
- (void)onConnectionRoomStateChanged:(QNConnectionState)state {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (state == QNConnectionStateConnected) {
      } else if (state == QNConnectionStateDisconnected) {
          [self.chatService sendLeaveMsg];
          [[QLive createPusherClient] leaveRoom];
          [self dismissViewControllerAnimated:YES completion:nil];
          [[QLive createPusherClient] stopRoomHeartBeart];
      }
    });
}

- (void)onUserLeaveRTC:(NSString *)userID {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (self.pk_other_user) {
          [self stopPK];
      }
    });
    
    // 异常离开
     QNMicLinker *rmlinker = nil;
     for (QNMicLinker *linker in self.linkMicList) {
         if ([linker.user.user_id isEqual:userID]) {
             if([_currentTracks.allKeys containsObject:userID]){
                 [_currentTracks removeObjectForKey:userID];
             }
             rmlinker = linker;
             break;
         }
     }
     if (rmlinker) {
         [self.linkMicList removeObject:rmlinker];
     }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.micLinkerCollectionView reloadData];
    });
}

- (void)didStartLiveStreaming:(NSString *)streamID {
    // 更新自己的混流布局
    if (self.pk_other_user) {
        CameraMergeOption *option = [CameraMergeOption new];
        option.frame = CGRectMake(0, 0, 720 / 2, 419);
        option.mZ = 0;
        [[[QLive createPusherClient] getMixStreamManager] updateUserVideoMixStreamingWithTrackId:[QLive createPusherClient].localVideoTrack.trackID option:option];
    }
}

- (void)onUserPublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID {
    dispatch_async(dispatch_get_main_queue(), ^{
      for (QNRemoteTrack *track in tracks) {
          if (track.kind == QNTrackKindVideo) {
              QNRemoteVideoTrack *videoTrack = (QNRemoteVideoTrack *)track;

              if (self.pk_other_user) {
                  self.preview.frame = CGRectMake(0, 130, SCREEN_W / 2, SCREEN_W / 1.5);
                  self.remoteView.frame = CGRectMake(SCREEN_W / 2, 130, SCREEN_W / 2, SCREEN_W / 1.5);
                  self.remoteView.layer.cornerRadius = 0;
                  [videoTrack play:self.remoteView];

                  [[[QLive createPusherClient] getMixStreamManager] updateMixStreamSize:CGSizeMake(720, 419)];
                  CameraMergeOption *userOption = [CameraMergeOption new];
                  userOption.frame = CGRectMake(720 / 2, 0, 720 / 2, 419);
                  userOption.mZ = 0;
                  [[[QLive createPusherClient] getMixStreamManager] updateUserVideoMixStreamingWithTrackId:videoTrack.trackID option:userOption];

              } else {
                  [self updateTrack:videoTrack userID:userID];
                  [self updatePublicPushLayout];
              }
          }
      }
    });
}

- (void)localVideoTrack:(QNLocalVideoTrack *)localVideoTrack didGetPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    QNCameraVideoTrack *track = (QNCameraVideoTrack *)localVideoTrack;

#ifdef useBeauty
    static st_mobile_human_action_t result;
    static st_mobile_animal_face_t animalResult;
    QNAllResult res;
    memset(&res, 0, sizeof(res));
    res.animal_result = &animalResult;
    res.humanResult = &result;

//    [self updateFirstEnterUI];

    QNDetectConfig detectConfig;
    memset(&detectConfig, 0, sizeof(QNDetectConfig));
    detectConfig.humanConfig = [self.effectManager getEffectDetectConfig];
    detectConfig.animalConfig = [self.effectManager getEffectAnimalDetectConfig];

    [self.detector detect:pixelBuffer cameraOrientation:track.videoOrientation detectConfig:detectConfig allResult:&res];
    [self.effectManager processBuffer:pixelBuffer cameraOrientation:track.videoOrientation detectResult:&res];
#endif
}

#pragma mark---------QNChatRoomServiceListener

- (void)onUserJoin:(QNLiveUser *)user message:(nonnull QNIMMessageObject *)message {
    [self.chatRoomView showMessage:message];
}

- (void)onUserLeave:(QNLiveUser *)user message:(QNIMMessageObject *)message {
    [self.chatRoomView showMessage:message];
}

// 收到弹幕
- (void)onReceivedDamaku:(PubChatModel *)msg {
    FDanmakuModel *model = [[FDanmakuModel alloc] init];
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

- (NSTimeInterval)currentTime {
    static double time = 0;
    time += 0.1;
    return time;
}

- (UIView *)danmakuViewWithModel:(FDanmakuModel *)model {
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor whiteColor];
    label.text = model.content;
    [label sizeToFit];
    return label;
}

- (void)didSendMessageModel:(QNIMMessageObject *)model {
    QIMModel *imModel = [QIMModel mj_objectWithKeyValues:model.content.mj_keyValues];
    PubChatModel *chatModel = [PubChatModel mj_objectWithKeyValues:imModel.data];
    if ([chatModel.action isEqualToString:living_danmu]) {
        FDanmakuModel *danmuModel = [[FDanmakuModel alloc] init];
        danmuModel.beginTime = 1;
        danmuModel.liveTime = 5;
        danmuModel.content = chatModel.content;
        [self.danmakuView.modelsArr addObject:danmuModel];
    }
    [self.statisticalService uploadComments];
}

// 收到公聊消息
- (void)onReceivedPuChatMsg:(PubChatModel *)msg message:(QNIMMessageObject *)message {
    [self.chatRoomView showMessage:message];
}

#pragma mark--------QLinkMicService---------

- (void)onUserJoinLink:(QNMicLinker *)micLinker {
    if([_currentTracks.allKeys containsObject:micLinker.user.user_id]){
        micLinker.track = _currentTracks[micLinker.user.user_id];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.micLinkerCollectionView reloadData];
    });;
    [self updatePublicPushLayout];
}

- (void)onUserLeaveLink:(QNMicLinker *)micLinker {
    for (QNMicLinker *linker in self.linkMicList) {
        if ([linker.user.user_id isEqual:micLinker.user.user_id]) {
            if([_currentTracks.allKeys containsObject:micLinker.user.user_id]){
                [_currentTracks removeObjectForKey:micLinker.user.user_id];
            }
            break;
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.micLinkerCollectionView reloadData];
    });;
    [self updatePublicPushLayout];
}

- (void)updateTrack:(QNTrack *)track userID:(NSString *)userID {
    for (QNMicLinker *linker in self.linkMicList) {
        if ([linker.user.user_id isEqual:userID]) {
            linker.track = track;
            break;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.micLinkerCollectionView reloadData];
    });;
}

- (void)updatePublicPushLayout{
    int frameY = 174;
    for (QNMicLinker *linker in self.linkMicList) {
        CameraMergeOption *userOption = [CameraMergeOption new];
        userOption.frame = CGRectMake(720 - 184 - 60, frameY , 184, 184);
        userOption.mZ = 1;
        [[[QLive createPusherClient] getMixStreamManager] updateUserVideoMixStreamingWithTrackId:linker.track.trackID option:userOption];
        
        frameY = frameY + 180 + 15;
    }
}


// 收到开关视频消息
- (void)onUserCameraStatusChange:(NSString *)uid mute:(BOOL)mute {
    self.remoteView.hidden = mute;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.micLinkerCollectionView reloadData];
    });;
}

// 收到开关音频消息
- (void)onUserMicrophoneStatusChange:(NSString *)uid mute:(BOOL)mute {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.micLinkerCollectionView reloadData];
    });;
}

// 接受到连麦邀请
- (void)onReceiveLinkInvitation:(QInvitationModel *)model {
    NSString *title = [model.invitation.linkInvitation.initiator.nick stringByAppendingString:@"申请加入连麦，是否同意？"];
    [QAlertView showBaseAlertWithTitle:title
        content:@""
        cancelHandler:^(UIAlertAction *_Nonnull action) {

        }
        confirmHandler:^(UIAlertAction *_Nonnull action) {
          [self.linkService AcceptLink:model];
        }];
}

// 接收到pk邀请
- (void)onReceivePKInvitation:(QInvitationModel *)model {
    NSString *title = [model.invitation.linkInvitation.initiator.nick stringByAppendingString:@"邀请您PK，是否同意？"];
    [QAlertView showBaseAlertWithTitle:title
        content:@""
        cancelHandler:^(UIAlertAction *_Nonnull action) {

        }
        confirmHandler:^(UIAlertAction *_Nonnull action) {
          [self.pkService AcceptPK:model];
          self.pk_other_user = model.invitation.linkInvitation.initiator;
        }];
}

// 收到同意pk邀请
- (void)onReceivePKInvitationAccept:(QNPKSession *)model {
    [QToastView showToast:@"对方主播同意pk"];
    self.pkSlot.selected = YES;
    self.pk_other_user = model.receiver;
}

// 收到开始pk信令
- (void)onReceiveStartPKSession:(QNPKSession *)pkSession {
    [QToastView showToast:@"pk马上开始"];
    self.pk_other_user = pkSession.initiator;
    self.pkSlot.selected = YES;
}

// 收到结束pk消息
- (void)onReceiveStopPKSession:(QNPKSession *)pkSession {
    [self stopPK];
}

// 主动结束pk
- (void)stopPK {
    self.pkSlot.selected = NO;
    self.preview.frame = self.view.frame;
    [self.renderBackgroundView bringSubviewToFront:self.preview];
    self.pk_other_user = nil;
    [self.pkService stopPK:nil];
}

#pragma mark - SubViews
- (RoomHostView *)roomHostView {
    if (!_roomHostView) {
        _roomHostView = [[RoomHostView alloc] initWithFrame:CGRectMake(8, 60, 135, 40)];
        [_roomHostView updateWith:self.roomInfo];
        ;
        _roomHostView.clickBlock = ^(BOOL selected) {
          NSLog(@"点击了房主头像");
        };
    }
    return _roomHostView;
}

- (OnlineUserView *)onlineUserView {
    if (!_onlineUserView) {
        _onlineUserView = [[OnlineUserView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 190, 60, 150, 60)];
        [_onlineUserView updateWith:self.roomInfo];
        _onlineUserView.clickBlock = ^(BOOL selected) {
          NSLog(@"点击了在线人数");
        };
    }
    return _onlineUserView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_W - 40, 70, 20, 20)];
        [_closeButton setImage:[UIImage imageNamed:@"icon_quit"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeViewController) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (ImageButtonView *)pubchatView {
    if (!_pubchatView) {
        _pubchatView = [[ImageButtonView alloc] initWithFrame:CGRectMake(15, SCREEN_H - 52.5, 170, 30)];
        _pubchatView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        _pubchatView.layer.cornerRadius = 15;
        _pubchatView.clipsToBounds = YES;

        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pub_chat"]];
        imageView.frame = CGRectMake(10, 7, 16, 16);
        [_pubchatView addSubview:imageView];

        __weak typeof(self) weakSelf = self;
        _pubchatView.clickBlock = ^(BOOL selected) {
          [weakSelf.chatRoomView commentBtnPressedWithPubchat:YES];
        };
    }
    return _pubchatView;
}

- (BottomMenuView *)bottomMenuView {
    if (!_bottomMenuView) {
        _bottomMenuView = [[BottomMenuView alloc] initWithFrame:CGRectMake(200, SCREEN_H - 60, SCREEN_W - 200, 45)];
    }
    return _bottomMenuView;
}

- (void)setupBottomMenuView {
    NSMutableArray *slotList = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;

    // 弹幕
    ImageButtonView *message = [[ImageButtonView alloc] initWithFrame:CGRectZero];
    [message bundleNormalImage:@"icon_danmu" selectImage:@"icon_danmu"];
    message.clickBlock = ^(BOOL selected) {
      [weakSelf.chatRoomView commentBtnPressedWithPubchat:NO];
    };
    [slotList addObject:message];

    // pk
    ImageButtonView *pk = [[ImageButtonView alloc] initWithFrame:CGRectZero];
    [pk bundleNormalImage:@"pk" selectImage:@"end_pk"];
    pk.clickBlock = ^(BOOL selected) {
      if (selected) {
          [[QLive getRooms] listRoom:1
                            pageSize:20
                            callBack:^(NSArray<QNLiveRoomInfo *> *_Nonnull list) {
                              [weakSelf popInvitationPKView:list];
                            }];
      } else {
          [weakSelf stopPK];
      }
    };
    [slotList addObject:pk];
    self.pkSlot = pk;

    // 购物车
    ImageButtonView *shopping = [[ImageButtonView alloc] initWithFrame:CGRectZero];
    [shopping bundleNormalImage:@"shopping" selectImage:@"shopping"];
    shopping.clickBlock = ^(BOOL selected) {
      [weakSelf popGoodListView];
    };
    [slotList addObject:shopping];

    // 更多
    ImageButtonView *more = [[ImageButtonView alloc] initWithFrame:CGRectZero];
    [more bundleNormalImage:@"icon_more" selectImage:@"icon_more"];
    more.clickBlock = ^(BOOL selected) {
      [weakSelf popMoreView];
    };
    [slotList addObject:more];

    [self.bottomMenuView updateWithSlotList:slotList.copy];
}

- (void)popMoreView {
    __weak typeof(self) weakSelf = self;
    self.moreView = [[LiveBottomMoreView alloc] initWithFrame:CGRectMake(0, SCREEN_H - 200, SCREEN_W, 200) beauty:YES];

    self.moreView.cameraChangeBlock = ^{
      [[QNLivePushClient createPushClient] switchCamera];
    };
    self.moreView.microphoneBlock = ^(BOOL mute) {
      [[QNLivePushClient createPushClient] muteMicrophone:mute];
    };
    self.moreView.cameraMirrorBlock = ^(BOOL mute) {
      [QNLivePushClient createPushClient].localVideoTrack.previewMirrorFrontFacing = !mute;
    };
#ifdef useBeauty
    self.moreView.beautyBlock = ^{
      [weakSelf clickBottomViewButton:weakSelf.beautyBtn];
    };
    self.moreView.effectsBlock = ^{
      [weakSelf clickBottomViewButton:weakSelf.specialEffectsBtn];
    };
#endif
    [self.view addSubview:self.moreView];
}

- (void)popGoodListView {
    ShopSellListController *vc = [[ShopSellListController alloc] initWithLiveInfo:self.roomInfo];
    vc.view.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
}

- (void)closeViewController {
    [QAlertView showThreeActionAlertWithTitle:@"确定关闭直播间吗？"
        content:@"关闭后无法再进入该直播间"
        firstAction:@"结束直播"
        firstHandler:^(UIAlertAction *_Nonnull action) {
          if (self.pk_other_user) {
              [self stopPK];
          }
          [self.chatService sendLeaveMsg];
          [[QLive createPusherClient] closeRoom];
          [self dismissViewControllerWithCount:2 animated:YES];
        }
        secondAction:@"仅暂停直播"
        secondHandler:^(UIAlertAction *_Nonnull action) {
          if (self.pk_other_user) {
              [self stopPK];
          }

          [[QLive createPusherClient] leaveRoom];
          [self dismissViewControllerWithCount:2 animated:YES];
        }
        threeHandler:^(UIAlertAction *_Nonnull action){

        }];
}

// 邀请面板
- (void)popInvitationPKView:(NSArray<QNLiveRoomInfo *> *)list {
    NSArray<QNLiveRoomInfo *> *resultList = [self filterListWithList:list];
    QNPKInvitationListController *vc = [[QNPKInvitationListController alloc] initWithList:resultList];
    __weak typeof(self) weakSelf = self;
    vc.invitationClickedBlock = ^(QNLiveRoomInfo *_Nonnull itemModel) {
      [weakSelf.pkService applyPK:itemModel.live_id receiveUser:itemModel.anchor_info];
      weakSelf.selectPkRoomInfo = itemModel;
      [QToastView showToast:@"pk邀请已发送"];
    };
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];

    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.right.equalTo(self.view);
      make.top.equalTo(self.view).offset(240);
      make.bottom.equalTo(self.view);
    }];
}

// 筛除掉自己的直播间
- (NSArray<QNLiveRoomInfo *> *)filterListWithList:(NSArray<QNLiveRoomInfo *> *)list {
    NSMutableArray *resultList = [NSMutableArray array];
    for (QNLiveRoomInfo *room in list) {
        if (![room.anchor_info.user_id isEqualToString:LIVE_User_id]) {
            [resultList addObject:room];
        }
    }
    return resultList;
}



#pragma mark - collection delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.linkMicList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QNVoiceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    QNMicLinker *model = self.linkMicList[indexPath.row];
    [cell configurateCollectionViewWithModle:model];


    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath ---------");
}

- (QStatisticalService *)statisticalService {
    if (!_statisticalService) {
        _statisticalService = [[QStatisticalService alloc] init];
        _statisticalService.roomInfo = self.roomInfo;
    }
    return _statisticalService;
}

- (QNGiftMessagePannel *)giftMessagePannel {
    if (!_giftMessagePannel) {
        _giftMessagePannel = [[QNGiftMessagePannel alloc] initWithFrame:CGRectMake(8, SCREEN_H - 315 - 150, 170, 150)];
    }
    return _giftMessagePannel;
}

- (QNLiveStatisticView *)statisticView {
    if (!_statisticView) {
        _statisticView = [[QNLiveStatisticView alloc] initWithFrame:CGRectMake(8, 108, 130, 16)];
        _statisticView.roomInfo = self.roomInfo;
    }
    return _statisticView;
}

@end
