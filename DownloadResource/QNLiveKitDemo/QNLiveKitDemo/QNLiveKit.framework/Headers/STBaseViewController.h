//
//  STBaseVC.h
//  SenseMeEffects
//
//  Created by sunjian on 2021/3/25.
//  Copyright © 2021 SenseTime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SenseArSourceService.h"
#import "STParamUtil.h"
#import "STCustomMemoryCache.h"
#import "EffectsCollectionViewCell.h"
#import "EffectsCollectionView.h"
#import "STCommonObjectContainerView.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "STFilterView.h"
#import "STBMPCollectionView.h"
#import "STBeautySlider.h"
#import "STScrollTitleView.h"
#import "STBmpStrengthView.h"
#import "STDefaultSetting.h"
#import "STSlideView.h"
#import "STTriggerView.h"
//st_mobile
#import "st_mobile_effect.h"
#import "st_mobile_license.h"

#import "STCoreStateManagement.h"
#import "STDefaultSettingDataSourseGenerator.h"

typedef NS_ENUM(NSInteger, STWriterRecordingStatus){
    STWriterRecordingStatusIdle = 0,
    STWriterRecordingStatusStartingRecording,
    STWriterRecordingStatusRecording,
    STWriterRecordingStatusStoppingRecording
};


typedef NS_ENUM(NSInteger, STViewTag) {
    STViewTagSpecialEffectsBtn = 10000,
    STViewTagBeautyBtn,
};


NS_ASSUME_NONNULL_BEGIN

@interface STBaseViewController : UIViewController<STBeautySliderDelegate, STBMPCollectionViewDelegate, STBmpStrengthViewDelegate>
{
    //TODO:
    st_handle_t _hEffectHandle;     // sticker句柄
    st_handle_t _hDetectorHandle;   // detector句柄
    st_handle_t _hAttributeHandle;  // attribute句柄
    st_handle_t _hTrackerHandle;    // 通用物体跟踪句柄
    st_handle_t _hAnimalHandle;     //猫脸
    st_handle_t _hAvatarHandle;     //avatar expression
    st_mobile_human_action_t _detectResult1;
    
    CVOpenGLESTextureCacheRef _cvTextureCache;
    
    //input
    CVOpenGLESTextureRef _cvTextureOrigin;
    GLuint _textureOriginInput;
    
    //output
    CVOpenGLESTextureRef _cvTextureOutput;
    CVPixelBufferRef _cvOutputBuffer;
    GLuint _textureOutput;

    //Makeup Model
    STMakeupDataModel *_bmp_Current_Model;
    STMakeupDataModel *_bmp_Pre_Model;
    STMakeupDataModel *_bmp_WholeMakeUp_Model;
    STMakeupDataModel *_bmp_EyeLiner_Model;
    STMakeupDataModel *_bmp_EyeLash_Model;
    STMakeupDataModel *_bmp_Lip_Model;
    STMakeupDataModel *_bmp_Brow_Model;
    STMakeupDataModel *_bmp_Nose_Model;
    STMakeupDataModel *_bmp_Blush_Model;
    STMakeupDataModel *_bmp_Cheek_Model;
    STMakeupDataModel *_bmp_Eyeball_Model;
    STMakeupDataModel *_bmp_Maskhair_Model;
    STMakeupDataModel *_bmp_EyeShadow_Model;
}

@property (nonatomic, strong) PLSTEffectManager *effectManager;


@property (nonatomic, strong) NSData *licenseData;
//@property (nonatomic, strong) STCustomMemoryCache *effectsDataSource;
//@property (nonatomic, assign) STEffectsType curEffectStickerType;
//@property (nonatomic, strong) NSArray *arrCurrentModels;
@property (nonatomic, strong) EffectsCollectionView *effectsList;
@property (nonatomic, strong) dispatch_queue_t thumbDownlaodQueue;
@property (nonatomic, strong) STCustomMemoryCache *thumbnailCache;
@property (nonatomic, strong) NSFileManager *fManager;
@property (nonatomic, strong) NSOperationQueue *imageLoadQueue;
@property (nonatomic,   copy) NSString *strThumbnailPath;
@property (nonatomic, assign) BOOL isFirstLaunch;
@property (nonatomic, assign) BOOL bFilter;
//@property (nonatomic, assign) BOOL needDetectAnimal;
//滤镜模型
//@property (nonatomic, strong) STCollectionViewDisplayModel *curSelFilterModel;
@property (nonatomic, strong) STCollectionViewDisplayModel *lastFilterModel;
@property (nonatomic, assign) int lastFilterModelIndex;
@property (nonatomic, strong) NSMutableSet *curSelMakeUps;
@property (nonatomic, strong) STCollectionViewDisplayModel *preFilterModel;
@property (nonatomic, strong) NSMutableArray *beforeStickerSelMakeUps;
@property (nonatomic, strong) NSMutableArray *selMakeUpsOther;
@property (nonatomic, assign) BOOL needRestoreWholeEffect;
//贴纸模型
//@property (nonatomic, strong) EffectsCollectionViewCellModel *coreStateMangement.prepareModel;
@property (nonatomic, assign) BOOL isWholeMakeUp;
//@property (nonatomic, assign) STEffectsType coreStateMangement.curEffectBeautyType;
@property (nonatomic, assign) BOOL bMakeUp;
@property (nonatomic, assign) unsigned long long iCurrentAction;
@property (nonatomic, assign) unsigned long long makeUpConf;
//@property (nonatomic, assign) unsigned long long coreStateMangement.stickerConf;
@property (nonatomic, assign) STBeautyType curBeautyBeautyType;
@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) CGFloat imageHeight;
@property (nonatomic, strong) EAGLContext *glContext;
@property (nonatomic, strong) STNewBeautyCollectionViewModel *currentModel;

//Data Sources
@property (nonatomic, strong) NSArray<STNewBeautyCollectionViewModel *> *wholeMakeUpModels;
@property (nonatomic, strong) NSArray<STNewBeautyCollectionViewModel *> *microSurgeryModels;
@property (nonatomic, strong) NSArray<STNewBeautyCollectionViewModel *> *baseBeautyModels;
@property (nonatomic, strong) NSArray<STNewBeautyCollectionViewModel *> *beautyShapeModels;
@property (nonatomic, strong) NSArray<STNewBeautyCollectionViewModel *> *adjustModels;

@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *m_wholeMakeArr;
@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *m_lipsArr;
@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *m_cheekArr;
@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *m_browsArr;
@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *m_eyeshadowArr;
@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *m_eyelinerArr;
@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *m_eyelashArr;
@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *m_noseArr;
@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *m_eyeballArr;
@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *m_maskhairArr;

@property (nonatomic, strong) NSMutableDictionary *filterDataSources; // 滤镜DataSource

//UI View
@property (nonatomic, strong) UIView *specialEffectsContainerView;
@property (nonatomic, strong) UIView *beautyContainerView;
@property (nonatomic, strong) UIView *filterCategoryView;
@property (nonatomic, strong) STFilterView *filterView;
@property (nonatomic, strong) STBMPCollectionView *bmpColView;
@property (nonatomic, strong) STBeautySlider *beautySlider;
@property (nonatomic, strong) STViewButton *specialEffectsBtn;
@property (nonatomic, strong) STViewButton *beautyBtn;
@property (nonatomic, strong) UIButton *btnCompare;
@property (nonatomic, strong) STScrollTitleView *scrollTitleView;
@property (nonatomic, strong) STScrollTitleView *beautyScrollTitleViewNew;
@property (nonatomic, strong) NSArray *arrObjectTrackers;
@property (nonatomic, strong) NSMutableArray<STViewButton *> *arrFilterCategoryViews;
@property (nonatomic, strong) STBmpStrengthView *bmpStrenghView;
@property (nonatomic, strong) STFilterCollectionView *filterCollectionView;
@property (nonatomic, strong) STNewBeautyCollectionView *beautyCollectionView;
@property (nonatomic, strong) UIView *filterStrengthView;
@property (nonatomic, strong) NSMutableArray *arrBeautyViews;
@property (nonatomic, strong) UISlider *filterStrengthSlider;
@property (nonatomic, strong) UIButton *resetBtn;
@property (nonatomic, strong) UILabel *filterStrength;
@property (nonatomic, strong) STCollectionView *objectTrackCollectionView;
@property (nonatomic, strong) STSlideView *sliderView;
@property (nonatomic, strong) STTriggerView *triggerView;
@property (nonatomic, assign) BOOL addSticker;
@property (nonatomic, strong) UIImageView *noneStickerImageView;

typedef NS_ENUM(NSUInteger, STCurrentType){
    STCurrentTypeWholeEffect,
    STCurrentTypeOther,
};

@property (nonatomic, assign) STCurrentType curType;

#pragma mark - Flag
@property (nonatomic, assign) BOOL specialEffectsContainerViewIsShow;
@property (nonatomic, assign) BOOL beautyContainerViewIsShow;
@property (nonatomic, assign) BOOL bRestored;
@property (nonatomic, assign) BOOL bAddSticker;

/// 通过获取overlap来判断是否是有美颜效果的贴纸 回调给设置贴纸的方法以判断是否取消掉整妆、美妆/滤镜 （4xx美妆、5xx滤镜）
@property (nonatomic, copy) void (^overlap_callback_block)(BOOL has4xx, BOOL has5xx);
/// 核心状态管理类
@property (nonatomic, strong) STCoreStateManagement * coreStateMangement;

- (void)initResourceAndStartPreview;
- (void)handleFilterChanged:(STCollectionViewDisplayModel *)model;
- (void)filterSliderValueChanged:(UISlider *)sender;
- (void)clickBottomViewButton:(STViewButton *)senderView;
- (void)handleEffectsType:(STEffectsType)type;
- (void)handleBeautyTypeChanged:(STNewBeautyCollectionViewModel *)model;
- (void)setupSubviews;
- (void)appWillResignActive;
- (void)appDidEnterBackground;
- (void)appWillEnterForeground;
- (void)appDidBecomeActive;
- (void)handleStickerChanged:(EffectsCollectionViewCellModel *)model;
- (void)setMaterialModel:(EffectsCollectionViewCellModel *)targetModel;
- (BOOL)checkMediaStatus:(NSString *)mediaType;
- (void)zeroBmp;
- (void)resetBmp;
- (void)setWholeMakeUpParam:(STBeautyType)beautyType;
- (void)diselectedWholeMakeup;
- (void)updateFilterViewDiselectFilter:(NSString *)deselctfilter
                          selectFilter:(NSString *)selectfilter;
- (NSUInteger)getBabyPinkFilterIndex:(NSString *)name;
- (NSUInteger)getBabyPinkFilterIndex;
- (void)resetBeautyValues:(UIButton *)sender;
- (void)refreshFilterCategoryState:(STEffectsType)type;
- (void)resetBmpModels;
- (void)cacheThumbnailOfModel:(EffectsCollectionViewCellModel *)model;
- (void)beautyContainerViewAppear;
- (void)resetWholeMakeupUIs;
- (void)handleObjectTrackChanged:(STCollectionViewDisplayModel *)model;
- (void)beautySliderValueChanged:(UISlider *)sender;
- (void)makeupSlideAction:(UISlider *)slider;
- (void)filterSlideAction:(UISlider *)slider;
- (void)processImageAndDisplay;
- (void)resetMakeup:(STBeautyType)type;
- (void)resetFilter:(STBeautyType)type;
- (void)getAddStickerResouces;
- (void)getBeautyParam:(BOOL)add;
- (void)zeroFilter;
- (void)showTrigleAction:(uint64_t)iAction;
- (void)getUIConfigFromDisk;
- (void)setBeautyParams;
- (NSMutableSet *)getSelectedMakeUps;
- (void)deSelectFilter;
- (void)deSelectMakup;
- (void)selectFilter;
- (void)selectMakeup;
/// 生成数据源
- (void)setupDefaultValus;
- (void)getOverLap;
- (void)onTapNoneSticker:(UITapGestureRecognizer *)tapGesture;
@end

NS_ASSUME_NONNULL_END
