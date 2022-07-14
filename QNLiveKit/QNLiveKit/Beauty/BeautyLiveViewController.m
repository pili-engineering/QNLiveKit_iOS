//
//  BeautyLiveViewController.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/30.
//

#import "BeautyLiveViewController.h"
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
#import "QAlertView.h"
#import "QInvitationModel.h"
#import "QRenderView.h"
#import "QLive.h"
#import "QNLiveUser.h"
#import "QNInvitationMemberListController.h"
#import "QPKService.h"
#import "LinkInvitation.h"
#import <QNRTCKit/QNRTCKit.h>
#import "FDanmakuView.h"
#import "FDanmakuModel.h"
#import "QIMModel.h"
#import "PubChatModel.h"
#import "QToastView.h"
#import <QNIMSDK/QNIMSDK.h>
#import <PLSTArEffects/PLSTArEffects.h>
#import "GoodsSellListController.h"
#import "GoodsModel.h"
#import "QLiveNetworkUtil.h"
#import "ExplainingGoodView.h"

@interface BeautyLiveViewController ()<QNPushClientListener,QNRoomLifeCycleListener,QNPushClientListener,QNChatRoomServiceListener,FDanmakuViewProtocol,LiveChatRoomViewDelegate,MicLinkerListener,PKServiceListener,QNLocalVideoTrackDelegate>

@property (nonatomic, strong) QNLiveRoomInfo *selectPkRoomInfo;
@property (nonatomic, strong) QNPKSession *pkSession;//正在进行的pk
@property (nonatomic, strong) QNLiveUser *pk_other_user;//pk对象
@property (nonatomic, strong) ImageButtonView *pkSlot;

//商汤特效
@property (nonatomic, strong) UIButton *effectButton;
@property (nonatomic, assign) BOOL isNullSticker;
@property (nonatomic, strong) PLSTEffectManager *effectManager;
@property (nonatomic, strong) PLSTDetector *detector;

@property (nonatomic, assign) BOOL isFirstWholeMakeUp;


@end

@implementation BeautyLiveViewController

+ (void)initialize {
    NSBundle *bud = [NSBundle mainBundle] ;
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SENSEME" ofType:@"lic"];
    NSData* license = [NSData dataWithContentsOfFile:path];
    [[STDefaultSetting sharedInstace] checkActiveCodeWithData:license];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.chatService removeChatServiceListener];
    [[QLive createPlayerClient] leaveRoom:self.roomInfo.live_id];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBG];
    
    __weak typeof(self)weakSelf = self;
    [[QLive createPusherClient] enableCamera:nil renderView:self.preview];
    [QLive createPusherClient].pushClientListener = self;
    [[QLive createPusherClient] setVideoFrameListener:self];
    self.linkService.micLinkerListener = self;
    self.pkService.delegate = self;
    self.danmakuView.delegate = self;
    self.chatRoomView.delegate = self;
    [self.chatService addChatServiceListener:self];
    [[QLive createPusherClient] startLive:self.roomInfo.live_id callBack:^(QNLiveRoomInfo * _Nonnull roomInfo) {
        self.roomInfo = roomInfo;
        [self updateRoomInfo];
    }];
    
    
    [self roomHostView];
    [self onlineUserView];
    [self pubchatView];
    [self bottomMenuView];
    [self setupSenseAR];
    self.beautyBtn.hidden = YES;
    self.specialEffectsBtn.hidden = YES;
    [self.chatService sendWelComeMsg:^(QNIMMessageObject * _Nonnull msg) {
        [weakSelf.chatRoomView showMessage:msg];
    }];
    
}

- (void)updateRoomInfo {
    [[QLive createPusherClient] roomHeartBeart:self.roomInfo.live_id];
    [[QLive getRooms] getRoomInfo:self.roomInfo.live_id callBack:^(QNLiveRoomInfo * _Nonnull roomInfo) {
        self.roomInfo = roomInfo;
        [self.roomHostView updateWith:roomInfo];
        [self.onlineUserView updateWith:roomInfo];
    }];
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

        } else if (state == QNConnectionStateDisconnected) {
            [self.chatService sendLeaveMsg];
            [[QLive createPusherClient] closeRoom];
            [QToastView showToast:@"您已离线"];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
    });
}

- (void)onUserLeaveRTC:(NSString *)userID {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.pk_other_user) {
            [self stopPK];
        }
    });
}

- (void)didStartLiveStreaming:(NSString *)streamID {
    //更新自己的混流布局
    if (self.pk_other_user) {
        CameraMergeOption *option = [CameraMergeOption new];
        option.frame = CGRectMake(0, 0, 720/2, 419);
        option.mZ = 0;
        [[[QLive createPusherClient] getMixStreamManager] updateUserVideoMixStreamingWithTrackId:[QLive createPusherClient].localVideoTrack.trackID option:option];
    }
}

- (void)onUserPublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for (QNRemoteTrack *track in tracks) {
            if (track.kind == QNTrackKindVideo) {
                QNRemoteVideoTrack *videoTrack = (QNRemoteVideoTrack *)track;
                QRenderView *remoteView = [[QRenderView alloc]initWithFrame:CGRectMake(SCREEN_W - 120, 120, 100, 100)];
                remoteView.userId = userID;
                remoteView.trackId = videoTrack.trackID;
                remoteView.layer.cornerRadius = 50;
                remoteView.clipsToBounds = YES;
                [self.renderBackgroundView addSubview:remoteView];
                [videoTrack play:remoteView];
                
                if (self.pk_other_user) {
                    
                    self.preview.frame = CGRectMake(0, 130, SCREEN_W/2, SCREEN_W/1.5);
                    remoteView.frame = CGRectMake(SCREEN_W/2, 130, SCREEN_W/2, SCREEN_W/1.5);
                    remoteView.layer.cornerRadius = 0;
                              
                    [[[QLive createPusherClient] getMixStreamManager] updateMixStreamSize:CGSizeMake(720, 419)];
                    CameraMergeOption *userOption = [CameraMergeOption new];
                    userOption.frame = CGRectMake(720/2, 0, 720/2, 419);
                    userOption.mZ = 0;
                    [[[QLive createPusherClient] getMixStreamManager] updateUserVideoMixStreamingWithTrackId:videoTrack.trackID option:userOption];
                    
                } else {
                    
                    [[[QLive createPusherClient] getMixStreamManager] updateMixStreamSize:CGSizeMake(720, 1280)];
                    CameraMergeOption *userOption = [CameraMergeOption new];
                    userOption.frame = CGRectMake(720-184-30, 200, 184, 184);
                    userOption.mZ = 1;
                    [[[QLive createPusherClient] getMixStreamManager] updateUserVideoMixStreamingWithTrackId:videoTrack.trackID option:userOption];
                }
            }
        }
    });
}

- (void)localVideoTrack:(QNLocalVideoTrack *)localVideoTrack didGetPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    
    QNCameraVideoTrack *track = (QNCameraVideoTrack *)localVideoTrack;
    
    static st_mobile_human_action_t result;
    static st_mobile_animal_face_t animalResult;
    QNAllResult res;
    memset(&res, 0, sizeof(res));
    res.animal_result = &animalResult;
    res.humanResult = &result;
    
    [self updateFirstEnterUI];
    
    QNDetectConfig detectConfig;
    memset(&detectConfig, 0, sizeof(QNDetectConfig));
    detectConfig.humanConfig = [self.effectManager getEffectDetectConfig];
    detectConfig.animalConfig = [self.effectManager getEffectAnimalDetectConfig];
    
    [self.detector detect:pixelBuffer cameraOrientation:track.videoOrientation detectConfig:detectConfig allResult:&res];
    [self.effectManager processBuffer:pixelBuffer cameraOrientation:track.videoOrientation detectResult:&res];
}

-(void)setupSenseAR{
    
    self.effectManager = [[PLSTEffectManager alloc] initWithContext:[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]];
    self.effectManager.effectOn = YES;
    _detector = [[PLSTDetector alloc] initWithConfig:ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_VIDEO];
    NSAssert(_detector, @"");
    
    [STDefaultSetting sharedInstace].effectManager = self.effectManager;

    NSString *subModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Segment_Head_1.0.3" ofType:@"model"];
    [_detector addSubModel:subModelPath];
    subModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Face_Video_7.0.0" ofType:@"model"];
    [_detector addSubModel:subModelPath];
    subModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Face_Extra_Advanced_6.0.13" ofType:@"model"];
    [_detector addSubModel:subModelPath];
    subModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Hand_5.4.0" ofType:@"model"];
    [_detector addSubModel:subModelPath];

    subModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Segment_4.12.8" ofType:@"model"];
    [_detector addSubModel:subModelPath];
    subModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Avatar_Help_2.2.0" ofType:@"model"];
    [_detector addSubModel:subModelPath];
    subModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Segment_Hair_1.3.4" ofType:@"model"];
    [_detector addSubModel:subModelPath];

    subModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseAR_Segment_MouthOcclusion_FastV1_1.1.2" ofType:@"model"];
    [_detector addSubModel:subModelPath];
    subModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Segment_Head_1.0.3" ofType:@"model"];
    [_detector addSubModel:subModelPath];
    
    subModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Segment_Sky_1.0.3" ofType:@"model"];
    [_detector addSubModel:subModelPath];
    
    //猫脸检测
    NSString *catFaceModel = [[NSBundle mainBundle] pathForResource:@"M_SenseME_CatFace_3.2.0" ofType:@"model"];
    [_detector addAnimalModelModel:catFaceModel];
    
    
    //狗脸检测
    NSString *dogFaceModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_DogFace_2.0.0" ofType:@"model"];
    [_detector addAnimalModelModel:dogFaceModelPath];
    
    //获取美颜数据源
    self.coreStateMangement.curEffectBeautyType = STEffectsTypeBeautyWholeMakeup;
    [self setupDefaultValus];
    [self setupSubviews];
//    _hEffectHandle = [self.effectManager getMobileEffectHandle];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STNewBeautyCollectionViewModel *model = self.wholeMakeUpModels[2];
        model.selected = YES;
        [self handleBeautyTypeChanged:model];
    });
}

- (void)setupSubviews {
    [super setupSubviews];
    [self.view addSubview:self.triggerView];
    [self.view addSubview:self.resetBtn];
}

#pragma mark - handle system notifications

- (void)appWillResignActive {
    
}

- (void)appDidEnterBackground {
   
}

- (void)applicationWillTerminate:(UIApplication *)application {

}

- (void)appWillEnterForeground {

}

- (void)appDidBecomeActive {

}


- (void)updateFirstEnterUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isFirstLaunch) {
            [self setDefaultBeautyValues];
            [self setDefaultMakeupValues];
            [self setWholeMakeUpParam:STBeautyTypeMakeupNvshen];
            [self resetMakeup: STBeautyTypeMakeupNvshen];
            [self resetFilter: STBeautyTypeMakeupNvshen];
            self.isWholeMakeUp = true;
            _isFirstWholeMakeUp = false;
            self.isFirstLaunch = NO;

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                STNewBeautyCollectionViewModel *model = self.wholeMakeUpModels[2];
                model.selected = YES;
                [self handleBeautyTypeChanged:model];
            });
            [self setBeautyParams];
        }else{
            if (self.isFirstWholeMakeUp){
//                [STDefaultSetting sharedInstace].glContext = self.glContext;
                //准备好数据
                [self setDefaultBeautyValues];
                [self setDefaultMakeupValues];
                self.isFirstWholeMakeUp = NO;
                self.bmpStrenghView.hidden = YES;
                self.filterStrengthView.hidden = YES;
                [self setBeautyParams];
            }
        }
    });
}

- (void)setDefaultBeautyValues{
    STDefaultSetting *setting = [STDefaultSetting sharedInstace];
    setting.wholeMakeUpModels = self.wholeMakeUpModels;
    setting.microSurgeryModels = self.microSurgeryModels;
    setting.baseBeautyModels = self.baseBeautyModels;
    setting.beautyShapeModels = self.beautyShapeModels;
    setting.adjustModels = self.adjustModels;
    setting.filterDataSources = self.filterDataSources;
    [setting setDefaultBeautyValues];
}

- (void)setDefaultMakeupValues{
    [[STDefaultSetting sharedInstace] getDefaultValue];
    STDefaultSetting *setting = [STDefaultSetting sharedInstace];
    setting.m_wholeMakeArr = self.m_wholeMakeArr;
    setting.m_lipsArr      = self.m_lipsArr;
    setting.m_cheekArr     = self.m_cheekArr;
    setting.m_browsArr     = self.m_browsArr;
    setting.m_eyeshadowArr = self.m_eyeshadowArr;
    setting.m_eyelinerArr  = self.m_eyelinerArr;
    setting.m_eyelashArr   = self.m_eyelashArr;
    setting.m_noseArr      = self.m_noseArr;
    setting.m_eyeballArr   = self.m_eyeballArr;
    setting.m_maskhairArr  = self.m_maskhairArr;
}

- (void)clickBottomViewButton:(STViewButton *)senderView {
    
    switch (senderView.tag) {
            
        case STViewTagSpecialEffectsBtn:
            
            self.beautyBtn.userInteractionEnabled = NO;
            
            if (!self.specialEffectsContainerViewIsShow) {
                
                [self hideBeautyContainerView];
                [self containerViewAppear];
            } else {
                
                [self hideContainerView];
            }
            
            self.beautyBtn.userInteractionEnabled = YES;
            
            break;
            
        case STViewTagBeautyBtn:
            
            self.specialEffectsBtn.userInteractionEnabled = NO;
            
            if (!self.beautyContainerViewIsShow) {
                

                [self hideContainerView];
                [self beautyContainerViewAppear];
                
            } else {
                
                [self hideBeautyContainerView];
            }
            self.beautySlider.hidden = YES;
            self.specialEffectsBtn.userInteractionEnabled = YES;
            [self.beautyCollectionView reloadData];
            break;
    }
    
}

- (void)beautyContainerViewAppear {
    if (self.coreStateMangement.curEffectBeautyType == self.beautyCollectionView.selectedModel.modelType) {
        self.beautySlider.hidden = NO;
    }
    
    self.beautyBtn.hidden = YES;
    self.specialEffectsBtn.hidden = YES;
    self.resetBtn.hidden = NO;
    
    self.filterCategoryView.center = CGPointMake(SCREEN_WIDTH / 2, self.filterCategoryView.center.y);
    self.filterView.center = CGPointMake(SCREEN_WIDTH * 3 / 2, self.filterView.center.y);
    
    [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.beautyContainerView.frame = CGRectMake(0, SCREEN_HEIGHT - 260, SCREEN_WIDTH, 260);
        self.btnCompare.frame = CGRectMake(SCREEN_WIDTH - 80, SCREEN_HEIGHT - 260 - 35.5 - 40, 70, 35);
        self.sliderView.frame = CGRectMake(0, SCREEN_HEIGHT - 430, SCREEN_WIDTH, 105);
        if (self.coreStateMangement.curEffectBeautyType == STEffectsTypeBeautyWholeMakeup) {
            for(int i = 0; i < self.wholeMakeUpModels.count; ++i){
                if (self.wholeMakeUpModels[i].selected) {
                    self.sliderView.hidden = NO;
                }
            }

        }
    } completion:^(BOOL finished) {
        self.beautyContainerViewIsShow = YES;
    }];
    self.beautyBtn.highlighted = YES;
}

- (void)hideContainerView {
    
    self.specialEffectsBtn.hidden = YES;
    self.beautyBtn.hidden = YES;
    
    [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.specialEffectsContainerView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 180);
        self.btnCompare.frame = CGRectMake(SCREEN_WIDTH - 80, SCREEN_HEIGHT - 150, 70, 35);
        
    } completion:^(BOOL finished) {
        self.specialEffectsContainerViewIsShow = NO;
    }];
    
    self.specialEffectsBtn.highlighted = NO;
}

- (void)containerViewAppear {
    
    self.filterStrengthView.hidden = YES;
    
    self.specialEffectsBtn.hidden = YES;
    self.beautyBtn.hidden = YES;
    
    [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.specialEffectsContainerView.frame = CGRectMake(0, SCREEN_HEIGHT - 230, SCREEN_WIDTH, 180);
        self.btnCompare.frame = CGRectMake(SCREEN_WIDTH - 80, SCREEN_HEIGHT - 250 - 35.5, 70, 35);
    } completion:^(BOOL finished) {
        self.specialEffectsContainerViewIsShow = YES;
    }];
    self.specialEffectsBtn.highlighted = YES;
}

- (void)hideBeautyContainerView {
    
    self.filterStrengthView.hidden = YES;
    self.beautySlider.hidden = YES;
    
    self.beautyBtn.hidden = YES;
    self.specialEffectsBtn.hidden = YES;
    self.resetBtn.hidden = YES;
    self.bmpStrenghView.hidden = YES;
    
    [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.beautyContainerView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 250);
        self.btnCompare.frame = CGRectMake(SCREEN_WIDTH - 80, SCREEN_HEIGHT - 150, 70, 35);
        self.sliderView.hidden = YES;
    } completion:^(BOOL finished) {
        self.beautyContainerViewIsShow = NO;
    }];
    
    self.beautyBtn.highlighted = NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self.view];
    
    if (self.specialEffectsContainerViewIsShow) {
        
        if (!CGRectContainsPoint(CGRectMake(0, SCREEN_HEIGHT - 230, SCREEN_WIDTH, 230), point)) {
            
            [self hideContainerView];
        }
    }
    
    if (self.beautyContainerViewIsShow) {
        
        if (!CGRectContainsPoint(CGRectMake(0, SCREEN_HEIGHT - 230, SCREEN_WIDTH, 230), point)) {
            
            [self hideBeautyContainerView];
        }
    }
    
    
    if (self.bmpColView) {
        
        [self.bmpColView backToMenu];
    }
}

#pragma mark - scroll title click events

- (void)onTapNoneSticker:(UITapGestureRecognizer *)tapGesture {
    
    [self cancelStickerAndObjectTrack];
    
    self.noneStickerImageView.highlighted = YES;
    
    [super onTapNoneSticker:tapGesture];
}


- (void)cancelStickerAndObjectTrack {
    
    self.objectTrackCollectionView.selectedModel.isSelected = NO;
    [self.objectTrackCollectionView reloadData];
    self.objectTrackCollectionView.selectedModel = nil;

}

- (void)handleEffectsType:(STEffectsType)type {
    [super handleEffectsType:type];
    if (!self.sliderView.isHidden && type != STEffectsTypeBeautyWholeMakeup) {
        self.sliderView.hidden = YES;
    }
    
    if (self.sliderView.isHidden &&
        type == STEffectsTypeBeautyWholeMakeup &&
        self.beautyContainerViewIsShow) {
        for(int i = 0; i < self.wholeMakeUpModels.count; ++i){
            if (self.wholeMakeUpModels[i].selected) {
                self.sliderView.hidden = NO;
            }
        }
    }
    
    switch (type) {
            
        case STEffectsTypeStickerMy:
        case STEffectsTypeSticker2D:
        case STEffectsTypeStickerAvatar:
        case STEffectsTypeSticker3D:
        case STEffectsTypeStickerGesture:
        case STEffectsTypeStickerSegment:
        case STEffectsTypeStickerFaceChange:
        case STEffectsTypeStickerFaceDeformation:
        case STEffectsTypeStickerParticle:
        case STEffectsTypeStickerNew:
        case STEffectsTypeObjectTrack:
        case STEffectsTypeStickerAdd:
            self.coreStateMangement.curEffectStickerType = type;
            break;
        case STEffectsTypeBeautyWholeMakeup:
        case STEffectsTypeBeautyFilter:
        case STEffectsTypeBeautyBase:
        case STEffectsTypeBeautyShape:
        case STEffectsTypeBeautyMicroSurgery:
        case STEffectsTypeBeautyAdjust:
        case STEffectsTypeBeautyMakeUp:
            self.coreStateMangement.curEffectBeautyType = type;
            [[STDefaultSetting sharedInstace] updateLastParamsCurType:type
                                                     wholeEffectModel:nil
                                                            baseModel:nil
                                                               filter:nil
                                                               makeup:nil
                                                        needWriteFile:NO];
            break;
        default:
            break;
    }
    
    if (type != STEffectsTypeBeautyFilter) {
        self.filterStrengthView.hidden = YES;
    }
    
    if (type == self.beautyCollectionView.selectedModel.modelType) {
        if (type == STEffectsTypeBeautyWholeMakeup) {
            self.beautySlider.hidden = YES;
        }else {
            self.beautySlider.hidden = !self.beautyContainerViewIsShow;
        }
    } else {
        self.beautySlider.hidden = YES;
    }
    
    switch (type) {
        case STEffectsTypeStickerAdd:{
            //reload data source
            [self getAddStickerResouces];
        }
        case STEffectsTypeStickerMy:
        case STEffectsTypeStickerNew:
        case STEffectsTypeSticker2D:
        case STEffectsTypeStickerAvatar:
        case STEffectsTypeStickerFaceDeformation:
        case STEffectsTypeStickerSegment:
        case STEffectsTypeSticker3D:
        case STEffectsTypeStickerGesture:
        case STEffectsTypeStickerFaceChange:
        case STEffectsTypeStickerParticle:
            
            self.objectTrackCollectionView.hidden = YES;
            
            self.coreStateMangement.arrCurrentModels = [self.coreStateMangement.effectsDataSource objectForKey:@(type)];
            [self.effectsList reloadData];
            
            self.effectsList.hidden = NO;
            
            break;
            
            
            
        case STEffectsTypeObjectTrack:
            
            [self resetCommonObjectViewPosition];
            
            self.objectTrackCollectionView.arrModels = self.arrObjectTrackers;
            self.objectTrackCollectionView.hidden = NO;
            self.effectsList.hidden = YES;
            [self.objectTrackCollectionView reloadData];
            
            break;
            
            
        case STEffectsTypeBeautyFilter:
            
            self.filterCategoryView.hidden = NO;
            self.filterView.hidden = NO;
            self.beautyCollectionView.hidden = YES;
            
            self.filterCategoryView.center = CGPointMake(SCREEN_WIDTH / 2, self.filterCategoryView.center.y);
            self.filterView.center = CGPointMake(SCREEN_WIDTH * 3 / 2, self.filterView.center.y);
            
            self.bmpColView.hidden = YES;
            self.bmpStrenghView.hidden = YES;
            
            break;
            
        case STEffectsTypeBeautyMakeUp:
            self.beautyCollectionView.hidden = YES;
            self.filterCategoryView.hidden = YES;
            self.filterView.hidden = YES;
            self.bmpColView.hidden = NO;
            self.beautySlider.hidden = YES;
        case STEffectsTypeNone:
            break;
            
        case STEffectsTypeBeautyShape:
            
//            [self hideBeautyViewExcept:self.beautyShapeView];
            self.filterStrengthView.hidden = YES;
            
            self.beautyCollectionView.hidden = NO;
            self.filterCategoryView.hidden = YES;
            self.beautyCollectionView.models = self.beautyShapeModels;
            [self.beautyCollectionView reloadData];
            
            self.bmpColView.hidden = YES;
            self.bmpStrenghView.hidden = YES;
            
            break;
            
        case STEffectsTypeBeautyBase:
            
            self.filterStrengthView.hidden = YES;
            [self hideBeautyViewExcept:self.beautyCollectionView];
            
            self.beautyCollectionView.hidden = NO;
            self.filterCategoryView.hidden = YES;
            self.beautyCollectionView.models = self.baseBeautyModels;
            [self.beautyCollectionView reloadData];
            
            self.bmpColView.hidden = YES;
            self.bmpStrenghView.hidden = YES;
            self.beautySlider.hidden = YES;

            
            break;
            
        case STEffectsTypeBeautyMicroSurgery:
            
            [self hideBeautyViewExcept:self.beautyCollectionView];
            self.beautyCollectionView.hidden = NO;
            self.filterCategoryView.hidden = YES;
            self.beautyCollectionView.models = self.microSurgeryModels;
            [self.beautyCollectionView reloadData];
            
            self.bmpColView.hidden = YES;
            self.bmpStrenghView.hidden = YES;
            
            break;
        case  STEffectsTypeBeautyWholeMakeup:
            
            [self hideBeautyViewExcept:self.beautyCollectionView];
            self.beautyCollectionView.hidden = NO;
            self.filterCategoryView.hidden = YES;
            self.beautyCollectionView.models = self.wholeMakeUpModels;
            [self.beautyCollectionView reloadData];
            
            self.bmpColView.hidden = YES;
            self.bmpStrenghView.hidden = YES;
            break;
        case STEffectsTypeBeautyAdjust:
            [self hideBeautyViewExcept:self.beautyCollectionView];
            self.beautyCollectionView.hidden = NO;
            self.filterCategoryView.hidden = YES;
            self.beautyCollectionView.models = self.adjustModels;
            [self.beautyCollectionView reloadData];
            
            self.bmpColView.hidden = YES;
            self.bmpStrenghView.hidden = YES;
            
            break;
            
            
        case STEffectsTypeBeautyBody:
            
            self.filterStrengthView.hidden = YES;
//            [self hideBeautyViewExcept:self.beautyBodyView];
            break;
            
        default:
            break;
    }
    switch (type) {
        case STEffectsTypeStickerFaceChange:
            //clear beauty make up
            [self resetWholeMakeupUIs];
            [self.bmpColView clearMakeUp];
            [self.beautyCollectionView reloadData];
            break;
        default:
            break;
    }
    
}

- (void)hideBeautyViewExcept:(UIView *)view {
    
    for (UIView *beautyView in self.arrBeautyViews) {
        
        beautyView.hidden = !(view == beautyView);
    }
}

- (void)resetCommonObjectViewPosition {
//    if (self.commonObjectContainerView.currentCommonObjectView) {
//        _commonObjectViewSetted = NO;
//        _commonObjectViewAdded = NO;
//        self.commonObjectContainerView.currentCommonObjectView.hidden = NO;
//        self.commonObjectContainerView.currentCommonObjectView.onFirst = YES;
//        self.commonObjectContainerView.currentCommonObjectView.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
//    }
}

#pragma mark - collectionview click events

- (void)handleFilterChanged:(STCollectionViewDisplayModel *)model {
    [super handleFilterChanged:model];
//    if (_hEffectHandle) {
        self.filterStrengthSlider.value = self.coreStateMangement.filterModel.value;
        [self refreshFilterCategoryState:model.modelType];
        
        [self.effectManager setBeautify:model.strPath type:EFFECT_BEAUTY_FILTER];
        [self.effectManager updateBeautify:model.value type:EFFECT_BEAUTY_FILTER];
//    }
}


- (void)handleObjectTrackChanged:(STCollectionViewDisplayModel *)model {
//    if (self.commonObjectContainerView.currentCommonObjectView) {
//        [self.commonObjectContainerView.currentCommonObjectView removeFromSuperview];
//    }
//    _commonObjectViewSetted = NO;
//    _commonObjectViewAdded = NO;
//
//    if (model.isSelected) {
//        UIImage *image = model.image;
//        [self.commonObjectContainerView addCommonObjectViewWithImage:image];
//        self.commonObjectContainerView.currentCommonObjectView.onFirst = YES;
//        self.bTracker = YES;
//    }
}



- (void)setMaterialModel:(EffectsCollectionViewCellModel *)targetModel{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.triggerView.hidden = YES;
    });
    
    const char *stickerPath = [targetModel.strMaterialPath UTF8String];
    
    if (!targetModel || IsSelected == targetModel.state) {
        
        stickerPath = NULL;
    }
    
    for (NSArray *arrModels in [self.coreStateMangement.effectsDataSource allValues]) {
        
        for (EffectsCollectionViewCellModel *model in arrModels) {
            
            if (model == targetModel) {
                
                if (IsSelected == model.state) {
                    
                    model.state = Downloaded;
                }else{
                    
                    model.state = IsSelected;
                }
            }else{
                
                if (IsSelected == model.state) {
                    
                    model.state = Downloaded;
                }
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.effectsList reloadData];
    });
    
    if (self.isNullSticker) {
        self.isNullSticker = NO;
    }
    
    //贴纸设置、取消时都要clear sticker value
    [[STDefaultSetting sharedInstace] clearStickerValue];
    
    st_result_t iRet = ST_OK;
    int packageId = 0;
    BOOL add = NO;
    if (targetModel.iEffetsType == STEffectsTypeStickerAdd) {
        self.addSticker = YES;
        if(self.coreStateMangement.addedStickerArray == nil) self.coreStateMangement.addedStickerArray = [NSMutableArray new];
        if ([self.coreStateMangement.addedStickerArray containsObject:targetModel]) {
            [self.coreStateMangement.addedStickerArray removeObject:targetModel];
            iRet = [self.effectManager removeSticker:targetModel.packageId];
            
            if (!self.coreStateMangement.addedStickerArray.count) {
                self.addSticker = NO;
            }
        }else{
            iRet = [self.effectManager addSticker:targetModel.strMaterialPath pID:&packageId];
            if(iRet != ST_OK) NSLog(@"st_mobile_effect_add_package error %d", iRet);
            else{
                [self.coreStateMangement.addedStickerArray addObject:targetModel];
                targetModel.packageId = packageId;
                add = YES;
            }
        }
    }else{
        if (stickerPath) {
            iRet = [self.effectManager updateSticker:targetModel.strMaterialPath pID:&packageId];
            self.coreStateMangement.prepareModel.packageId = packageId;
            add = YES;
        }else{
            iRet =[self.effectManager removeSticker:self.coreStateMangement.prepareModel.packageId];
            self.coreStateMangement.prepareModel.packageId = 0;
        }
    }
    [self getBeautyParam:add];
    
    // 获取触发动作类型
    unsigned long long iAction = 0;
    
    if (iRet != ST_OK && iRet != ST_E_PACKAGE_EXIST_IN_MEMORY) {
        
        NSLog(@"st_mobile_sticker_change_package error %d" , iRet);
    } else {
        iAction = [self.effectManager getEffectDetectConfig];
        [self showTrigleAction:iAction];
        
        //猫脸config
        unsigned long long animalConfig = 0;
        animalConfig = [self.effectManager getEffectDetectConfig];
        if (iRet == ST_OK && CHECK_FLAG(animalConfig, ST_MOBILE_CAT_DETECT)) {
            self.coreStateMangement.needDetectAnimal = YES;
        } else {
            self.coreStateMangement.needDetectAnimal = NO;
        }
    }
    self.coreStateMangement.stickerConf = iAction;
}
#pragma mark - senseMeEffects --------------------  end --------------------



#pragma mark ---------QNChatRoomServiceListener

- (void)onUserJoin:(QNLiveUser *)user message:(nonnull QNIMMessageObject *)message {
    [self.chatRoomView showMessage:message];
}

- (void)onUserLeave:(QNLiveUser *)user message:(QNIMMessageObject *)message {
    [self.chatRoomView showMessage:message];
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
}

//收到下麦消息
- (void)onReceivedDownMic:(QNMicLinker *)linker {
    QRenderView *userView = [self getUserView:linker.user.user_id];
    [userView removeFromSuperview];
}

//收到公聊消息
- (void)onReceivedPuChatMsg:(PubChatModel *)msg message:(QNIMMessageObject *)message {
    [self.chatRoomView showMessage:message];
}

//收到开关视频消息
- (void)onReceivedVideoMute:(BOOL)mute user:(NSString *)uid {
    QRenderView *userView = [self getUserView:uid];
    userView.hidden = mute;
}

//收到开关音频消息
- (void)onReceivedAudioMute:(BOOL)mute user:(NSString *)uid {
    
}

//接受到连麦邀请
- (void)onReceiveLinkInvitation:(QInvitationModel *)model {
    NSString *title = [model.invitation.msg.initiator.nick stringByAppendingString:@"申请加入连麦，是否同意？"];
    [QAlertView showBaseAlertWithTitle:title content:@"" handler:^(UIAlertAction * _Nonnull action) {
        [self.linkService AcceptLink:model];
    }];
}

//接收到pk邀请
- (void)onReceivePKInvitation:(QInvitationModel *)model {
    NSString *title = [model.invitation.msg.initiator.nick stringByAppendingString:@"邀请您PK，是否同意？"];
    [QAlertView showBaseAlertWithTitle:title content:@"" handler:^(UIAlertAction * _Nonnull action) {
        [self.pkService AcceptPK:model];
        self.pk_other_user = model.invitation.msg.initiator;
    }];
}

//收到同意pk邀请
- (void)onReceivePKInvitationAccept:(QNPKSession *)model {
    [QToastView showToast:@"对方主播同意pk"];
    self.pkSlot.selected = YES;
    self.pk_other_user = model.receiver;
}

//收到开始pk信令
- (void)onReceiveStartPKSession:(QNPKSession *)pkSession {
    [QToastView showToast:@"pk马上开始"];
    self.pk_other_user = pkSession.initiator;
    self.pkSlot.selected = YES;
}

//收到结束pk消息
- (void)onReceiveStopPKSession:(QNPKSession *)pkSession {
    [self stopPK];
}

//主动结束pk
- (void)stopPK {
    self.pkSlot.selected = NO;
    self.preview.frame = self.view.frame;
    [self.renderBackgroundView bringSubviewToFront:self.preview];
    self.pk_other_user = nil;
    [self.pkService stopPK:nil];
}

- (RoomHostView *)roomHostView {
    if (!_roomHostView) {
        _roomHostView = [[RoomHostView alloc]initWithFrame:CGRectMake(20, 60, 135, 40)];
        [self.view addSubview:_roomHostView];
        [_roomHostView updateWith:self.roomInfo];;
        _roomHostView.clickBlock = ^(BOOL selected) {
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
        };
    }
    return _onlineUserView;
}

- (ImageButtonView *)pubchatView {
    if (!_pubchatView) {
        _pubchatView = [[ImageButtonView alloc]initWithFrame:CGRectMake(15, SCREEN_H - 60, 100, 45)];
        [_pubchatView bundleNormalImage:@"chat_input_bar" selectImage:@"chat_input_bar"];
        [self.view addSubview:_pubchatView];
        
        __weak typeof(self)weakSelf = self;
        _pubchatView.clickBlock = ^(BOOL selected){
            [weakSelf.chatRoomView commentBtnPressedWithPubchat:YES];
        };
    }
    return _pubchatView;
}

- (BottomMenuView *)bottomMenuView {
    if (!_bottomMenuView) {
        
        _bottomMenuView = [[BottomMenuView alloc]initWithFrame:CGRectMake(130, SCREEN_H - 60, SCREEN_W - 130, 45)];
        [self.view addSubview:_bottomMenuView];
        
        NSMutableArray *slotList = [NSMutableArray array];
        __weak typeof(self)weakSelf = self;
        //pk
        ImageButtonView *pk = [[ImageButtonView alloc]initWithFrame:CGRectZero];
        [pk bundleNormalImage:@"pk" selectImage:@"end_pk"];
        pk.clickBlock = ^(BOOL selected){
            if (!selected) {
                [[QLive getRooms] listRoom:1 pageSize:20 callBack:^(NSArray<QNLiveRoomInfo *> * _Nonnull list) {
                    [weakSelf popInvitationPKView:list];
                }];
            } else {
                [weakSelf stopPK];
            }
        };
        [slotList addObject:pk];
        self.pkSlot = pk;
        
        //购物车
        ImageButtonView *shopping = [[ImageButtonView alloc]initWithFrame:CGRectZero];
        [shopping bundleNormalImage:@"shopping" selectImage:@"shopping"];
        shopping.clickBlock = ^(BOOL selected){
            [weakSelf popGoodListView];
        };
        [slotList addObject:shopping];
        
        //美颜
        ImageButtonView *beauty = [[ImageButtonView alloc]initWithFrame:CGRectZero];
        [beauty bundleNormalImage:@"btn_beauty" selectImage:@"btn_beauty_selected"];
        beauty.clickBlock = ^(BOOL selected) {
            [weakSelf clickBottomViewButton:weakSelf.beautyBtn];
        };
        [slotList addObject:beauty];
        
        //特效
        ImageButtonView *specialEffects = [[ImageButtonView alloc]initWithFrame:CGRectZero];
        [specialEffects bundleNormalImage:@"btn_special_effects" selectImage:@"btn_special_effects_selected"];
        specialEffects.clickBlock = ^(BOOL selected) {
            [weakSelf clickBottomViewButton:weakSelf.specialEffectsBtn];
        };
        [slotList addObject:specialEffects];
        
        //弹幕
        ImageButtonView *message = [[ImageButtonView alloc]initWithFrame:CGRectZero];
        [message bundleNormalImage:@"message" selectImage:@"message"];
        message.clickBlock = ^(BOOL selected){
            [weakSelf.chatRoomView commentBtnPressedWithPubchat:NO];
        };
        [slotList addObject:message];
        //关闭
        ImageButtonView *close = [[ImageButtonView alloc]initWithFrame:CGRectZero];
        [close bundleNormalImage:@"live_close" selectImage:@"live_close"];
        close.clickBlock = ^(BOOL selected){
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        };
        [slotList addObject:close];
        
        [_bottomMenuView updateWithSlotList:slotList.copy];
        
    }
    return _bottomMenuView;
}

- (void)popGoodListView {
        
        GoodsSellListController *vc = [[GoodsSellListController alloc] initWithLiveID:self.roomInfo.live_id];
        vc.view.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self addChildViewController:vc];
        [self.view addSubview:vc.view];
        
}

//邀请面板
- (void)popInvitationPKView:(NSArray<QNLiveRoomInfo *> *)list {
    
    NSArray<QNLiveRoomInfo *> *resultList = [self filterListWithList:list];
    QNInvitationMemberListController *vc = [[QNInvitationMemberListController alloc] initWithList:resultList];
    __weak typeof(self)weakSelf = self;
    vc.invitationClickedBlock = ^(QNLiveRoomInfo * _Nonnull itemModel) {
       
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

 //筛除掉自己的直播间
- (NSArray<QNLiveRoomInfo *> *)filterListWithList:(NSArray<QNLiveRoomInfo *> *)list{
    NSMutableArray *resultList = [NSMutableArray array];
    for (QNLiveRoomInfo *room in list) {
        if (![room.anchor_info.user_id isEqualToString:QN_User_id]) {
            [resultList addObject:room];
        }
    }
    return resultList;
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
    self.preview.fillMode = QNVideoFillModePreserveAspectRatioAndFill;
    [self.renderBackgroundView addSubview:self.preview];
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
        if (![userView.userId isEqualToString:QN_User_id]) {
            [userView removeFromSuperview];
        }
    }];
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
