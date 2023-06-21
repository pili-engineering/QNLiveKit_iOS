//
//  QNLiveBaseController.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/18.
//

#import "QNLiveBaseController.h"
#import "RoomHostView.h"
#import "OnlineUserView.h"
#import "BottomMenuView.h"
#import "QRenderView.h"
#import "FDanmakuView.h"
#import "LiveChatRoom.h"

#ifdef useBeauty
#import <PLSTArEffects/PLSTArEffects.h>
#import "QNBeautyManager.h"
#endif

@interface QNLiveBaseController ()

@end

@implementation QNLiveBaseController



-(void)dealloc{
    NSLog(@"QNLiveBaseController dealloc");
    //确保 _chatService 能正常销毁
    if (_chatService) {
        [_chatService removeChatServiceListener];
    }
}

#ifdef useBeauty
#pragma mark - effect
- (void)effectButtonDidClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.specialEffectsBtn.hidden = sender.selected;
    self.beautyBtn.hidden = sender.selected;
}

- (void)setupSubviews {
    [super setupSubviews];

    [self.view addSubview:self.triggerView];
    [self.view addSubview:self.resetBtn];
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
                STNewBeautyCollectionViewModel *model = self.wholeMakeUpModels[0];
                model.selected = YES;
                [self handleBeautyTypeChanged:model];
            });
            [self setBeautyParams];
        }else{
            if (self.isFirstWholeMakeUp){
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
    
//    self.specialEffectsBtn.hidden = NO;
//    self.beautyBtn.hidden = NO;
    
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
    
//    self.beautyBtn.hidden = NO;
//    self.specialEffectsBtn.hidden = NO;
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
            [self.effectManager removeSticker:targetModel.packageId];
            if (!self.coreStateMangement.addedStickerArray.count) {
                self.addSticker = NO;
            }
        }else{
            [self.effectManager addSticker:targetModel.strMaterialPath pID:&packageId];
            if(iRet != ST_OK) NSLog(@"st_mobile_effect_add_package error %d", iRet);
            else{
                [self.coreStateMangement.addedStickerArray addObject:targetModel];
                targetModel.packageId = packageId;
                add = YES;
            }
        }
    }else{
        if (stickerPath) {
            [self.effectManager updateSticker:targetModel.strMaterialPath pID:&packageId];
            self.coreStateMangement.prepareModel.packageId = packageId;
            add = YES;
        }else{
            [self.effectManager removeSticker:self.coreStateMangement.prepareModel.packageId];
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
        if (ST_OK != iRet) {
            NSLog(@"st_mobile_sticker_get_trigger_action error %d" , iRet);
            return;
        }
        [self showTrigleAction:iAction];
        
        //猫脸config
        unsigned long long animalConfig = 0;
        animalConfig = [self.effectManager getEffectAnimalDetectConfig];
        if (iRet == ST_OK && CHECK_FLAG(animalConfig, ST_MOBILE_CAT_DETECT)) {
            self.coreStateMangement.needDetectAnimal = YES;
        } else {
            self.coreStateMangement.needDetectAnimal = NO;
        }
    }
    self.coreStateMangement.stickerConf = iAction;
}

#pragma mark - senseMeEffects --------------------  end --------------------
#endif


- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupBG];
    
#ifdef useBeauty
    //获取美颜数据源
    self.coreStateMangement.curEffectBeautyType = STEffectsTypeBeautyWholeMakeup;
    [self setupDefaultValus];
    [self setupSubviews];
    
    [[QNBeautyManager shardManager] initSuccess:^(BOOL state) {
        if (state){
            self.effectManager = [[QNBeautyManager shardManager] getEffectManager];
            self.detector = [[QNBeautyManager shardManager] getDetector];
            [STDefaultSetting sharedInstace].effectManager = self.effectManager;
            [self setDefaultBeautyValues];

        }else{
            NSLog(@"鉴权失败");
        }
    }];
    
//    _hEffectHandle = [_effectManager getMobileEffectHandle];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STNewBeautyCollectionViewModel *model = self.wholeMakeUpModels[0];
        model.selected = YES;
        [self handleBeautyTypeChanged:model];
    });
#endif
    
}

- (void)setupBG {
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"live_bg"]];
    bg.frame = self.view.frame;
    [self.view addSubview:bg];
    [self.view sendSubviewToBack:bg];
    
    self.renderBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H)];
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
        _linkService = [[QLinkMicService alloc] initWithRoomInfo:self.roomInfo];
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
