//
//  STBaseVC.m
//  SenseMeEffects
//
//  Created by sunjian on 2021/3/25.
//  Copyright © 2021 SenseTime. All rights reserved.
//

#import "STBaseViewController.h"
#import "STConvert.h"
#import "UIView+Toast.h"
#import "DefaultBeautyParameters.h"

#import <YYModel/YYModel.h>
//沙河路径
#define kDocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

@interface STBaseViewController () <STCoreStateManagementValueChangeDelegate>

@end

@implementation STBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupThumbnailCache];
    [self setupSenseArService];
    [self requestPermissions];
    [self addNotifications];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self isMemberOfClass:[UIViewController class]]) {
        [[STDefaultSetting sharedInstace] updateLastParamsCurType:self.coreStateMangement.curEffectBeautyType
                                                 wholeEffectModel:self.coreStateMangement.currentWholeMakeUpModel
                                                        baseModel:self.currentModel
                                                           filter:self.coreStateMangement.filterModel
                                                           makeup:nil
                                                    needWriteFile:NO];
    }
}

- (void)setupThumbnailCache{
    self.thumbDownlaodQueue = dispatch_queue_create("com.sensetime.thumbDownloadQueue", DISPATCH_QUEUE_SERIAL);
    self.imageLoadQueue = [[NSOperationQueue alloc] init];
    self.imageLoadQueue.maxConcurrentOperationCount = 20;
    
    self.thumbnailCache = [[STCustomMemoryCache alloc] init];
    self.fManager = [[NSFileManager alloc] init];
    
    self.strThumbnailPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"senseme_thumbnail"];
    
    NSError *error = nil;
    BOOL bCreateSucceed = [self.fManager createDirectoryAtPath:self.strThumbnailPath
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error];
    if (!bCreateSucceed || error) {
        NSLog(@"create thumbnail cache directory failed !");
        NSArray *actions = @[@"知道了"];
        UIAlertController *alertVC = [STParamUtil showAlertWithTitle:@"提示" Message:@"创建列表图片缓存文件夹失败" actions:actions onVC:self];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

- (void)requestPermissions {
    ALAssetsLibrary *photoLibrary = [[ALAssetsLibrary alloc] init];
    [photoLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:nil failureBlock:nil];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {}];
    
    
    self.isFirstLaunch = [[NSUserDefaults standardUserDefaults] objectForKey:@"FIRSTLAUNCH"] == nil;
    if (self.isFirstLaunch) {
        [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"FIRSTLAUNCH"];
    }
}


- (void)addNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    
}
-(void) setupSenseArService{
    [self fetchLists];
}


- (void)initResourceAndStartPreview{}

//使用服务器拉取的license进行本地鉴权
- (BOOL)checkLicenseFromServer {
    self.licenseData = [[SenseArMaterialService sharedInstance] getLicenseData];
    return [[STDefaultSetting sharedInstace] checkActiveCodeWithData:self.licenseData];
}
//使用本地license进行本地鉴权
- (BOOL)checkLicenseFromLocal {
    self.licenseData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SENSEME" ofType:@"lic"]];
    return [[STDefaultSetting sharedInstace] checkActiveCodeWithData:self.licenseData];
}

- (void)setupMakeUpDataSources{
    STDefaultSettingDataSourseGenerator * generator = [[STDefaultSettingDataSourseGenerator alloc] init];
    [generator stm_generatMakeupDataSourceWholeMake:^(NSArray<STMakeupDataModel *> *wholeMakeDatasource) {
        self.m_wholeMakeArr = [wholeMakeDatasource mutableCopy];
        [STDefaultSetting sharedInstace].m_wholeMakeArr = self.m_wholeMakeArr;
        
        //默认美妆效果
        [self.bmpColView wholeMakeUp:STBeautyTypeMakeupNvshen];
        self.bmpStrenghView.hidden = YES;
        [self.beautyCollectionView reloadData];
        
    } andLips:^(NSArray<STMakeupDataModel *> *lipsDatasource) {
        self.m_lipsArr = [lipsDatasource mutableCopy];
        [STDefaultSetting sharedInstace].m_lipsArr = self.m_lipsArr;
    } andCheek:^(NSArray<STMakeupDataModel *> *cheekDatasource) {
        self.m_cheekArr = [cheekDatasource mutableCopy];
        [STDefaultSetting sharedInstace].m_cheekArr = self.m_cheekArr;
    } andBrows:^(NSArray<STMakeupDataModel *> *browsDatasource) {
        self.m_browsArr = [browsDatasource mutableCopy];
        [STDefaultSetting sharedInstace].m_browsArr = self.m_browsArr;
    } andEyeshadow:^(NSArray<STMakeupDataModel *> *eyeshadowDatasource) {
        self.m_eyeshadowArr = [eyeshadowDatasource mutableCopy];
        [STDefaultSetting sharedInstace].m_eyeshadowArr = self.m_eyeshadowArr;
    } andEyeliner:^(NSArray<STMakeupDataModel *> *eyelinerDatasource) {
        self.m_eyelinerArr = [eyelinerDatasource mutableCopy];
        [STDefaultSetting sharedInstace].m_eyelinerArr = self.m_eyelinerArr;
    } andEyelash:^(NSArray<STMakeupDataModel *> *eyelashDatasource) {
        self.m_eyelashArr = [eyelashDatasource mutableCopy];
        [STDefaultSetting sharedInstace].m_eyelashArr = self.m_eyelashArr;
    } andNose:^(NSArray<STMakeupDataModel *> *noseDatasource) {
        self.m_noseArr = [noseDatasource mutableCopy];
        [STDefaultSetting sharedInstace].m_noseArr = self.m_noseArr;
    } andEyeball:^(NSArray<STMakeupDataModel *> *eyeballDatasource) {
        self.m_eyeballArr = [eyeballDatasource mutableCopy];
        [STDefaultSetting sharedInstace].m_eyeballArr = self.m_eyeballArr;
    } andMaskhair:^(NSArray<STMakeupDataModel *> *maskhairDatasource) {
        self.m_maskhairArr = [maskhairDatasource mutableCopy];
        [STDefaultSetting sharedInstace].m_maskhairArr = self.m_maskhairArr;
    }];
}

/// 生成数据源
- (void)setupDefaultValus{
    STDefaultSettingDataSourseGenerator * generator = [[STDefaultSettingDataSourseGenerator alloc] init];
    [[[[[[generator stm_generatWholeMakeUpDataSource:^(NSArray<STNewBeautyCollectionViewModel *> *datasource) { // 整体效果
        self.wholeMakeUpModels = datasource;
    }]
         stm_generatMicroSurgeryDataSource:^(NSArray<STNewBeautyCollectionViewModel *> *datasource) { // 微整形
        self.microSurgeryModels = datasource; //micro 19
    }]
        stm_generatBaseBeautyDataSource:^(NSArray<STNewBeautyCollectionViewModel *> *datasource) { // 基础美颜
        self.baseBeautyModels = datasource; //beauty value 6
    }] stm_generatBeautyShapeDataSource:^(NSArray<STNewBeautyCollectionViewModel *> *datasource) { // 美形
        self.beautyShapeModels = datasource; //shapen 5
    }] stm_generatAdjustDataSource:^(NSArray<STNewBeautyCollectionViewModel *> *datasource) { // 调整
        self.adjustModels = datasource; //adjust 4
    }] stm_generatFilterDataSource:^(NSDictionary<id,NSArray<STCollectionViewDisplayModel *> *> *datasource) { // 滤镜
        self.filterDataSources = [datasource mutableCopy]; //STEffectsTypeBeautyFilter
    }];
}

- (void)fetchLists {
//    [[STDefaultSetting sharedInstace] setupMakeUpDataSources];
    [self setupMakeUpDataSources];
    
    self.coreStateMangement.effectsDataSource = [[STCustomMemoryCache alloc] init];
    
    NSString *strLocalBundlePath = [[NSBundle mainBundle] pathForResource:@"my_sticker" ofType:@"bundle"];
    
    if (strLocalBundlePath) {
        
        NSMutableArray *arrLocalModels = [NSMutableArray array];
        
        NSFileManager *fManager = [[NSFileManager alloc] init];
        
        NSArray *arrFiles = [fManager contentsOfDirectoryAtPath:strLocalBundlePath error:nil];
        
        int indexOfItem = 0;
        for (NSString *strFileName in arrFiles) {
            
            if ([strFileName hasSuffix:@".zip"]) {
                
                NSString *strMaterialPath = [strLocalBundlePath stringByAppendingPathComponent:strFileName];
                NSString *strThumbPath = [[strMaterialPath stringByDeletingPathExtension] stringByAppendingString:@".png"];
                UIImage *imageThumb = [UIImage imageNamed:strThumbPath];
                
                if (!imageThumb) {
                    imageThumb = [UIImage imageNamed:@"none"];
                }
                EffectsCollectionViewCellModel *model = [[EffectsCollectionViewCellModel alloc] init];
                
                model.iEffetsType = STEffectsTypeStickerMy;
                model.state = Downloaded;
                model.indexOfItem = indexOfItem;
                model.imageThumb = imageThumb;
                model.strMaterialPath = strMaterialPath;
                
                [arrLocalModels addObject:model];
                
                indexOfItem ++;
            }
        }
        
        NSString *strDocumentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        NSString *localStickerPath = [strDocumentsPath stringByAppendingPathComponent:@"local_sticker"];
        if (![fManager fileExistsAtPath:localStickerPath]) {
            [fManager createDirectoryAtPath:localStickerPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSArray *arrFileNames = [fManager contentsOfDirectoryAtPath:localStickerPath error:nil];
        
        for (NSString *strFileName in arrFileNames) {
            
            if ([strFileName hasSuffix:@"zip"]) {
                
                NSString *strMaterialPath = [localStickerPath stringByAppendingPathComponent:strFileName];
                NSString *strThumbPath = [[strMaterialPath stringByDeletingPathExtension] stringByAppendingString:@".png"];
                UIImage *imageThumb = [UIImage imageWithContentsOfFile:strThumbPath];
                
                if (!imageThumb) {
                    
                    imageThumb = [UIImage imageNamed:@"none"];
                }
                
                EffectsCollectionViewCellModel *model = [[EffectsCollectionViewCellModel alloc] init];
                
                model.iEffetsType = STEffectsTypeStickerMy;
                model.state = Downloaded;
                model.indexOfItem = indexOfItem;
                model.imageThumb = imageThumb;
                model.strMaterialPath = strMaterialPath;
                
                [arrLocalModels addObject:model];
                
                indexOfItem ++;
            }
        }
        [self.coreStateMangement.effectsDataSource setObject:arrLocalModels
                                                      forKey:@(STEffectsTypeStickerMy)];
    }
    
    self.coreStateMangement.curEffectStickerType = STEffectsTypeStickerNew;
        
    [self fetchMaterialsAndReloadDataWithGroup];
    [self getAddStickerResouces];

}

- (void)getAddStickerResouces{
    NSString *strDocumentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *localStickerPath = [strDocumentsPath stringByAppendingPathComponent:@"local_sticker"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:localStickerPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:localStickerPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSMutableArray<EffectsCollectionViewCellModel *> *arrLocalModels = [NSMutableArray array];
    NSArray *arrFileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:localStickerPath error:nil];
    int indexOfItem = 0;
    for (NSString *strFileName in arrFileNames) {
        if ([strFileName hasSuffix:@"zip"]) {
            NSString *strMaterialPath = [localStickerPath stringByAppendingPathComponent:strFileName];
            NSString *strThumbPath = [[strMaterialPath stringByDeletingPathExtension] stringByAppendingString:@".png"];
            UIImage *imageThumb = [UIImage imageWithContentsOfFile:strThumbPath];
            if (!imageThumb) {
                imageThumb = [UIImage imageNamed:@"none"];
            }
            EffectsCollectionViewCellModel *model = [[EffectsCollectionViewCellModel alloc] init];
            model.iEffetsType = STEffectsTypeStickerAdd;
            model.state = Downloaded;
            model.indexOfItem = indexOfItem;
           
            model.imageThumb = imageThumb;
            model.strMaterialPath = strMaterialPath;
            [arrLocalModels addObject:model];
            indexOfItem ++;
        }
    }
    [self.coreStateMangement.effectsDataSource setObject:arrLocalModels
                                                  forKey:@(STEffectsTypeStickerAdd)];
}
-(void)fetchMaterialsAndReloadDataWithGroup{
    [[EFDataSourceGenerator sharedInstance] efGeneratAllDataSourceWithCallback:^(id<EFDataSourcing> datasource) {

        self.arrModelAll = [NSMutableArray array];
        for (EFDataSourceModel * materialClassOne in datasource.efSubDataSources) {
            NSInteger one = 0;
            for (EFDataSourceModel *materialClassTwo in materialClassOne.efSubDataSources) {
                NSInteger two = 0;
                NSMutableArray *arrModel = [NSMutableArray array];
                for (EFDataSourceModel *matericalClassThree in materialClassTwo.efSubDataSources) {
                    
                    EffectsCollectionViewCellModel *model = [[EffectsCollectionViewCellModel alloc] init];
                    model.NewMaterial = matericalClassThree;
                   switch([[EFMaterialDownloadStatusManager sharedInstance] efDownloadStatus:matericalClassThree]) {
                       case EFMaterialDownloadStatusNotDownload:
                           model.state = NotDownloaded;
                           break;
                       case EFMaterialDownloadStatusDownloading:
                           model.state = IsDownloading;
                           break;
                       case EFMaterialDownloadStatusDownloaded:
                           model.state = Downloaded;
                           break;
                   };
                    model.NameOne = materialClassOne.efName;
                    model.NameTwo = materialClassTwo.efName;
                    model.NameThree = matericalClassThree.efName;
                    if ([materialClassOne.efName  isEqual: @"Avatar"] || [materialClassOne.efName  isEqual: @"滤镜"] || [materialClassOne.efName  isEqual: @"美妆"]) {
                        
                        model.iEffetsType = [self efNameToSTEffectsType:materialClassOne.efName];
                    }else{
                        
                        model.iEffetsType = [self efNameToSTEffectsType:materialClassTwo.efName];
                    }
                    
                    if (matericalClassThree.efMaterialPath) {
                        model.strMaterialPath = matericalClassThree.efMaterialPath;
                    }
                    model.imageThumbUrl = matericalClassThree.efThumbnailDefault;
                    model.NewMaterial = matericalClassThree;
                    model.indexOfItem = (int)two;
                    [arrModel addObject:model];
                    [self.arrModelAll addObject:model];
                    two++;
                    
                }
                [self.coreStateMangement.effectsDataSource setObject:arrModel forKey:@([self efNameToSTEffectsType:materialClassTwo.efName])];
//                if ([self efNameToSTEffectsType:materialClassTwo.efName] == self.coreStateMangement.curEffectStickerType) {

                if([self efNameToSTEffectsType:materialClassTwo.efName] == STEffectsTypeSticker2D){
                    self.coreStateMangement.arrCurrentModels = [self.coreStateMangement.effectsDataSource objectForKey:@([self efNameToSTEffectsType:materialClassTwo.efName])];
                    
                    [self.effectsList reloadData];

                }
                one++;
            }
        }
        
            for (EffectsCollectionViewCellModel *model in _arrModelAll) {
                
                dispatch_async(self.thumbDownlaodQueue, ^{

                        [self cacheThumbnailOfModel:model];
                    
                    
                });
            }
//        dispatch_sync(self.thumbDownlaodQueue, ^{
//            NSLog(@"加载完成---------------");
//            self.scrollTitleView.userInteractionEnabled =NO;
////            [self.effectsList reloadData];
//
//        });
//        dispatch_sync(self.thumbDownlaodQueue, ^{
//            self.scrollTitleView.userInteractionEnabled = YES;
//        });
        [self getAddStickerResouces];
        
//        [self.effectsList reloadData];
    }];
    
    
}
//efName 转STEffectsType
-(STEffectsType)efNameToSTEffectsType:(NSString *)efName{
    if ([efName isEqual:@"最新"]) {
        return STEffectsTypeStickerNew;
    }
    else if ([efName isEqual:@"2D贴纸"]){
        return STEffectsTypeSticker2D;
    }
    else if ([efName isEqual:@"3D贴纸"]){
        return STEffectsTypeSticker3D;
    }
    else if ([efName isEqual:@"手势贴纸"]){
        return STEffectsTypeStickerGesture;
    }
    else if ([efName isEqual:@"分割"]){
        return STEffectsTypeStickerSegment;
    }
    else if ([efName isEqual:@"脸部变形"]){
        return STEffectsTypeStickerFaceDeformation;
    }
    else if ([efName isEqual:@"粒子效果"]){
        return STEffectsTypeStickerParticle;
    }
    else if ([efName isEqual:@"大头特效"]){
        return STEffectsTypeStickerFaceChange;
    }
    else if ([efName isEqual:@"Avatar"]){
        return STEffectsTypeStickerAvatar;
    }
    else if ([efName isEqual:@"基础美颜"]){
        return STEffectsTypeBeautyBase;
    }
    else if ([efName isEqual:@"美形"]){
        return STEffectsTypeBeautyShape;
    }
    else if ([efName isEqual:@"微整形"]){
        return STEffectsTypeBeautyMicroSurgery;
    }
    else if ([efName isEqual:@"调整"]){
        return STEffectsTypeBeautyAdjust;
    }
    else if ([efName isEqual:@"滤镜"]){
        return STEffectsTypeBeautyFilter;
    }
    else if ([efName isEqual:@"美妆"]){
        return STEffectsTypeBeautyMakeUp;
    }
    else {
        return STEffectsTypeNone;
    }

}


- (void)cacheThumbnailOfModel:(EffectsCollectionViewCellModel *)model{
    __weak typeof(self) weakSelf = self;
    NSString *strFileID = model.NewMaterial.efMaterialPath;
    
    id cacheObj = [weakSelf.thumbnailCache objectForKey:strFileID];
    
    if (!cacheObj || ![cacheObj isKindOfClass:[UIImage class]]) {
        
        NSString *strThumbnailImagePath = [weakSelf.strThumbnailPath stringByAppendingPathComponent:strFileID];
        
        if (![weakSelf.fManager fileExistsAtPath:strThumbnailImagePath]) {
            
            [weakSelf.thumbnailCache setObject:strFileID forKey:strFileID];
            
            
            [weakSelf.imageLoadQueue addOperationWithBlock:^{
                
                UIImage *imageDownloaded = nil;
                
                if ([model.imageThumbUrl isKindOfClass:[NSString class]] && [NSURL URLWithString:model.imageThumbUrl]) {
                    
                    NSError *error = nil;
                    
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.imageThumbUrl] options:NSDataReadingMappedIfSafe error:&error];
                    
                    imageDownloaded = [UIImage imageWithData:imageData];
                    
                    if (imageDownloaded) {
                        
                        if ([weakSelf.fManager createFileAtPath:strThumbnailImagePath contents:imageData attributes:nil]) {
                            
                            [weakSelf.thumbnailCache setObject:imageDownloaded forKey:strFileID];
                        }else{
                            
                            [weakSelf.thumbnailCache removeObjectForKey:strFileID];
                        }
                    }else{
                        
                        [weakSelf.thumbnailCache removeObjectForKey:strFileID];
                    }
                }else{
                    
                    [weakSelf.thumbnailCache removeObjectForKey:strFileID];
                }
                
                model.imageThumb = imageDownloaded;
                
                if (weakSelf.coreStateMangement.curEffectStickerType == model.iEffetsType) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [weakSelf.effectsList reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:model.indexOfItem inSection:0]]];
//                        [weakSelf.effectsList reloadData];
                    });
                }
            }];
        }else{
            
            UIImage *image = [UIImage imageNamed:strThumbnailImagePath];
            
            if (image) {
                
                [weakSelf.thumbnailCache setObject:image forKey:strFileID];
                
            }else{
                
                [weakSelf.fManager removeItemAtPath:strThumbnailImagePath error:nil];
            }
        }
    }
}

- (void)setupSubviews {
    [self.view addSubview:self.specialEffectsContainerView];
    [self.view addSubview:self.beautyContainerView];
    [self.view addSubview:self.filterStrengthView];
    [self.view addSubview:self.beautySlider];
    [self.view addSubview:self.specialEffectsBtn];
    [self.view addSubview:self.beautyBtn];
    [self.view addSubview:self.btnCompare];
    [self.view addSubview:self.sliderView];
#if ENABLE_FACE_ATTRIBUTE_DETECT
    [self.view addSubview:self.lblAttribute];
#endif
#if ST_REPLAY
    [self.view addSubview:self.btnReplay];
#endif
    //test add and remove submodels
#if ENABLE_DYNAMIC_ADD_AND_REMOVE_MODELS
    [self.view addSubview:self.lblBodyAction];
#endif
}

- (UIView *)specialEffectsContainerView {
    if (!_specialEffectsContainerView) {
        _specialEffectsContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 230)];
        _specialEffectsContainerView.backgroundColor = [UIColor clearColor];
        
        UIView *noneStickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 57, 40)];
        noneStickerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        noneStickerView.layer.shadowColor = UIColorFromRGB(0x141618).CGColor;
        noneStickerView.layer.shadowOpacity = 0.5;
        noneStickerView.layer.shadowOffset = CGSizeMake(3, 3);
        
        UIImage *image = [UIImage imageNamed:@"none_sticker.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((57 - image.size.width) / 2, (40 - image.size.height) / 2, image.size.width, image.size.height)];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.image = image;
        imageView.highlightedImage = [UIImage imageNamed:@"none_sticker_selected.png"];
        //        _noneStickerImageView = imageView;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapNoneSticker:)];
        [noneStickerView addGestureRecognizer:tapGesture];
        
        [noneStickerView addSubview:imageView];
        
        UIView *whiteLineView = [[UIView alloc] initWithFrame:CGRectMake(56, 3, 1, 34)];
        whiteLineView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
        [noneStickerView addSubview:whiteLineView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, 1)];
        lineView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
        [_specialEffectsContainerView addSubview:lineView];
        
        [_specialEffectsContainerView addSubview:noneStickerView];
        [_specialEffectsContainerView addSubview:self.effectsList];
        [_specialEffectsContainerView addSubview:self.scrollTitleView];
        [_specialEffectsContainerView addSubview:self.objectTrackCollectionView];
        
        UIView *blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 181, SCREEN_WIDTH, 50)];
        blankView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [_specialEffectsContainerView addSubview:blankView];
    }
    return _specialEffectsContainerView;
}

- (void)onTapNoneSticker:(UITapGestureRecognizer *)tapGesture{
//    [self getBeautyParam:NO];
    //update sticker UIs
    [[STDefaultSetting sharedInstace] clearStickerValue];
    [self.coreStateMangement.addedStickerArray removeAllObjects];
    self.coreStateMangement.prepareModel.state = Downloaded;
    [self.effectsList reloadData];
    //update 效果
    st_result_t iRet =  [self.effectManager updateSticker:NULL pID:NULL];
    if (ST_OK != iRet) {
        NSLog(@"st_mobile_sticker_change_package error %d", iRet);
    }
    STWeakSelf;
    _overlap_callback_block = ^(BOOL has4xx, BOOL has5xx) {
        STStrongSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!has4xx && !has5xx) {
                [strongSelf restoreStickerStateBeayManu:NO];
            }
        });
        weakSelf.overlap_callback_block = nil;
    };
}
- (EffectsCollectionView *)effectsList
{
    
    STWeakSelf;
    if (!_effectsList) {
        
        _effectsList = [[EffectsCollectionView alloc] initWithFrame:CGRectMake(0, 41, SCREEN_WIDTH, 140)];
        [_effectsList registerNib:[UINib nibWithNibName:@"EffectsCollectionViewCell"
                                                 bundle:[NSBundle mainBundle]]
       forCellWithReuseIdentifier:@"EffectsCollectionViewCell"];
        
        _effectsList.numberOfSectionsInView = ^NSInteger(STCustomCollectionView *collectionView) {
            
            return 1;
        };
        _effectsList.numberOfItemsInSection = ^NSInteger(STCustomCollectionView *collectionView, NSInteger section) {
//            EffectsCollectionViewCellModel *model = weakSelf.coreStateMangement.arrCurrentModels[section];
//            if (model.iEffetsType == STEffectsTypeStickerGesture) {
//                NSLog(@"手势 %ld ---------",(unsigned long)weakSelf.coreStateMangement.arrCurrentModels.count);
//            }
            return weakSelf.coreStateMangement.arrCurrentModels.count;
        };
        _effectsList.cellForItemAtIndexPath = ^UICollectionViewCell *(STCustomCollectionView *collectionView, NSIndexPath *indexPath) {
            
            static NSString *strIdentifier = @"EffectsCollectionViewCell";
            
            EffectsCollectionViewCell *cell = (EffectsCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:strIdentifier forIndexPath:indexPath];
           
//            int start=0;
            NSArray *arrModels = weakSelf.coreStateMangement.arrCurrentModels;
            
            if (arrModels.count) {
                
                EffectsCollectionViewCellModel *model = arrModels[indexPath.item];
                if (model.iEffetsType != STEffectsTypeStickerMy && model.iEffetsType != STEffectsTypeStickerAdd) {
                    
                    id cacheObj = [weakSelf.thumbnailCache objectForKey:model.material.strMaterialFileID];
                    
                    if (cacheObj && [cacheObj isKindOfClass:[UIImage class]]) {
                        
                        model.imageThumb = cacheObj;
                    }else{
                        
                        model.imageThumb = [UIImage imageNamed:@"none"];
                    }
                }
                
                cell.model = model;
                
                return cell;
            }else{
                
                cell.model = nil;
                
                return cell;
            }
        };
        _effectsList.didSelectItematIndexPath = ^(STCustomCollectionView *collectionView, NSIndexPath *indexPath) {
            
            NSArray *arrModels = weakSelf.coreStateMangement.arrCurrentModels;
            
            weakSelf.noneStickerImageView.highlighted = NO;
            
            [weakSelf handleStickerChanged:arrModels[indexPath.item]];
        };
    }
    return _effectsList;
}
- (UIView *)beautyContainerView {
    
    if (!_beautyContainerView) {
        _beautyContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 260)];
        _beautyContainerView.backgroundColor = [UIColor clearColor];
        [_beautyContainerView addSubview:self.beautyScrollTitleViewNew];
        
        UIView *whiteLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, 1)];
        whiteLineView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
        [_beautyContainerView addSubview:whiteLineView];
        
        [_beautyContainerView addSubview:self.filterCategoryView];
        [_beautyContainerView addSubview:self.filterView];
        [_beautyContainerView addSubview:self.bmpColView];
        [_beautyContainerView addSubview:self.beautyCollectionView];
        
        [self.arrBeautyViews addObject:self.filterCategoryView];
        [self.arrBeautyViews addObject:self.filterView];
        [self.arrBeautyViews addObject:self.beautyCollectionView];
    }
    return _beautyContainerView;
}

- (STFilterView *)filterView {
    
    if (!_filterView) {
        
        _filterView = [[STFilterView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 41, SCREEN_WIDTH, 300)];
        _filterView.leftView.imageView.image = [UIImage imageNamed:@"still_life_highlighted"];
        _filterView.leftView.titleLabel.text = @"静物";
        _filterView.leftView.titleLabel.textColor = [UIColor whiteColor];
        
        _filterView.filterCollectionView.arrSceneryFilterModels = self.filterDataSources[@(STEffectsTypeFilterScenery)];
        _filterView.filterCollectionView.arrPortraitFilterModels = self.filterDataSources[@(STEffectsTypeFilterPortrait)];
        _filterView.filterCollectionView.arrStillLifeFilterModels = self.filterDataSources[@(STEffectsTypeFilterStillLife)];
        _filterView.filterCollectionView.arrDeliciousFoodFilterModels = self.filterDataSources[@(STEffectsTypeFilterDeliciousFood)];
        
        STWeakSelf;
        _filterView.filterCollectionView.delegateBlock = ^(STCollectionViewDisplayModel *model) {
            [weakSelf manuHandleFilter];
            [weakSelf handleFilterChanged:model];
        };
        _filterView.block = ^{
            [UIView animateWithDuration:0.5 animations:^{
                weakSelf.filterCategoryView.frame = CGRectMake(0, weakSelf.filterCategoryView.frame.origin.y, SCREEN_WIDTH, 300);
                weakSelf.filterView.frame = CGRectMake(SCREEN_WIDTH, weakSelf.filterView.frame.origin.y, SCREEN_WIDTH, 300);
            }];
            weakSelf.filterStrengthView.hidden = YES;
        };
    }
    return _filterView;
}

- (UIView *)filterCategoryView {
    if (!_filterCategoryView) {
        _filterCategoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 41, SCREEN_WIDTH, 300)];
        _filterCategoryView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        STViewButton *portraitViewBtn = [[[NSBundle mainBundle] loadNibNamed:@"STViewButton" owner:nil options:nil] firstObject];
        portraitViewBtn.tag = STEffectsTypeFilterPortrait;
        portraitViewBtn.backgroundColor = [UIColor clearColor];
        portraitViewBtn.frame =  CGRectMake(SCREEN_WIDTH / 2 - 143, 20, 40, 70);
        portraitViewBtn.imageView.image = [UIImage imageNamed:@"portrait"];
        portraitViewBtn.imageView.highlightedImage = [UIImage imageNamed:@"portrait_highlighted"];
        portraitViewBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        portraitViewBtn.titleLabel.textColor = [UIColor whiteColor];
        portraitViewBtn.titleLabel.highlightedTextColor = [UIColor whiteColor];
        portraitViewBtn.titleLabel.text =  NSLocalizedString(@"人物", nil);
        
        for (UIGestureRecognizer *recognizer in portraitViewBtn.gestureRecognizers) {
            [portraitViewBtn removeGestureRecognizer:recognizer];
        }
        UITapGestureRecognizer *portraitRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchFilterType:)];
        [portraitViewBtn addGestureRecognizer:portraitRecognizer];
        [self.arrFilterCategoryViews addObject:portraitViewBtn];
        [_filterCategoryView addSubview:portraitViewBtn];
        
        
        
        STViewButton *sceneryViewBtn = [[[NSBundle mainBundle] loadNibNamed:@"STViewButton" owner:nil options:nil] firstObject];
        sceneryViewBtn.tag = STEffectsTypeFilterScenery;
        sceneryViewBtn.backgroundColor = [UIColor clearColor];
        sceneryViewBtn.frame =  CGRectMake(SCREEN_WIDTH / 2 - 60, 20, 40, 70);
        sceneryViewBtn.imageView.image = [UIImage imageNamed:@"scenery"];
        sceneryViewBtn.imageView.highlightedImage = [UIImage imageNamed:@"scenery_highlighted"];
        sceneryViewBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        sceneryViewBtn.titleLabel.textColor = [UIColor whiteColor];
        sceneryViewBtn.titleLabel.highlightedTextColor = [UIColor whiteColor];
        sceneryViewBtn.titleLabel.text = NSLocalizedString(@"风景", nil);
        
        for (UIGestureRecognizer *recognizer in sceneryViewBtn.gestureRecognizers) {
            [sceneryViewBtn removeGestureRecognizer:recognizer];
        }
        UITapGestureRecognizer *sceneryRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchFilterType:)];
        [sceneryViewBtn addGestureRecognizer:sceneryRecognizer];
        [self.arrFilterCategoryViews addObject:sceneryViewBtn];
        [_filterCategoryView addSubview:sceneryViewBtn];
        STViewButton *stillLifeViewBtn = [[[NSBundle mainBundle] loadNibNamed:@"STViewButton" owner:nil options:nil] firstObject];
        stillLifeViewBtn.tag = STEffectsTypeFilterStillLife;
        stillLifeViewBtn.backgroundColor = [UIColor clearColor];
        stillLifeViewBtn.frame =  CGRectMake(SCREEN_WIDTH / 2 + 27, 20, 40, 70);
        stillLifeViewBtn.imageView.image = [UIImage imageNamed:@"still_life"];
        stillLifeViewBtn.imageView.highlightedImage = [UIImage imageNamed:@"still_life_highlighted"];
        stillLifeViewBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        stillLifeViewBtn.titleLabel.textColor = [UIColor whiteColor];
        stillLifeViewBtn.titleLabel.highlightedTextColor = [UIColor whiteColor];
        stillLifeViewBtn.titleLabel.text = NSLocalizedString(@"静物", nil);
        for (UIGestureRecognizer *recognizer in stillLifeViewBtn.gestureRecognizers) {
            [stillLifeViewBtn removeGestureRecognizer:recognizer];
        }
        UITapGestureRecognizer *stillLifeRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchFilterType:)];
        [stillLifeViewBtn addGestureRecognizer:stillLifeRecognizer];
        [self.arrFilterCategoryViews addObject:stillLifeViewBtn];
        [_filterCategoryView addSubview:stillLifeViewBtn];
        STViewButton *deliciousFoodViewBtn = [[[NSBundle mainBundle] loadNibNamed:@"STViewButton" owner:nil options:nil] firstObject];
        deliciousFoodViewBtn.tag = STEffectsTypeFilterDeliciousFood;
        deliciousFoodViewBtn.backgroundColor = [UIColor clearColor];
        deliciousFoodViewBtn.frame =  CGRectMake(SCREEN_WIDTH / 2 + 110, 20, 40, 70);
        deliciousFoodViewBtn.imageView.image = [UIImage imageNamed:@"delicious_food"];
        deliciousFoodViewBtn.imageView.highlightedImage = [UIImage imageNamed:@"delicious_food_highlighted"];
        deliciousFoodViewBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        deliciousFoodViewBtn.titleLabel.textColor = [UIColor whiteColor];
        deliciousFoodViewBtn.titleLabel.highlightedTextColor = [UIColor whiteColor];
        deliciousFoodViewBtn.titleLabel.text = NSLocalizedString(@"美食", nil);
        
        for (UIGestureRecognizer *recognizer in deliciousFoodViewBtn.gestureRecognizers) {
            [deliciousFoodViewBtn removeGestureRecognizer:recognizer];
        }
        UITapGestureRecognizer *deliciousFoodRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchFilterType:)];
        [deliciousFoodViewBtn addGestureRecognizer:deliciousFoodRecognizer];
        [self.arrFilterCategoryViews addObject:deliciousFoodViewBtn];
        [_filterCategoryView addSubview:deliciousFoodViewBtn];
        
    }
    return _filterCategoryView;
}

/// 美妆效果列表 view
- (STBMPCollectionView *)bmpColView{
    if (!_bmpColView) {
        _bmpColView = [[STBMPCollectionView alloc] initWithFrame:CGRectMake(0, 41, SCREEN_WIDTH, 220)];
        _bmpColView.delegate = self;
        _bmpColView.hidden = YES;
        _bmpStrenghView = [[STBmpStrengthView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 260 - 35.5, SCREEN_WIDTH, 35.5)];
        _bmpStrenghView.backgroundColor = [UIColor clearColor];
        _bmpStrenghView.hidden = YES;
        _bmpStrenghView.delegate = self;
        [self.view addSubview:_bmpStrenghView];
    }
    return _bmpColView;
}


- (STCollectionView *)objectTrackCollectionView {
    if (!_objectTrackCollectionView) {
        
        __weak typeof(self) weakSelf = self;
        _objectTrackCollectionView = [[STCollectionView alloc] initWithFrame:CGRectMake(0, 41, SCREEN_WIDTH, 140) withModels:nil andDelegateBlock:^(STCollectionViewDisplayModel *model) {
            [weakSelf handleObjectTrackChanged:model];
        }];
        
        _objectTrackCollectionView.arrModels = self.arrObjectTrackers;
        _objectTrackCollectionView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _objectTrackCollectionView;
}

- (STNewBeautyCollectionView *)beautyCollectionView {
    if (!_beautyCollectionView) {
        STWeakSelf;
        _beautyCollectionView = [[STNewBeautyCollectionView alloc] initWithFrame:CGRectMake(0, 41, SCREEN_WIDTH, 220) models:self.baseBeautyModels delegateBlock:^(STNewBeautyCollectionViewModel *model) {
            
            [weakSelf handleBeautyTypeChanged:model];
        }];
        _beautyCollectionView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [_beautyCollectionView reloadData];
    }
    return _beautyCollectionView;
}

#pragma - 滤镜相关UI
- (UIView *)filterStrengthView {
    if (!_filterStrengthView) {
        //background view
        _filterStrengthView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 260 - 35.5, SCREEN_WIDTH, 35.5)];
        _filterStrengthView.backgroundColor = [UIColor clearColor];
        _filterStrengthView.hidden = YES;
        
        UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 10, 35.5)];
        leftLabel.textColor = [UIColor whiteColor];
        leftLabel.font = [UIFont systemFontOfSize:11];
        leftLabel.text = @"0";
        [_filterStrengthView addSubview:leftLabel];
        
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(40, 0, SCREEN_WIDTH - 90, 35.5)];
        slider.thumbTintColor = UIColorFromRGB(0x9e4fcb);
        slider.minimumTrackTintColor = UIColorFromRGB(0x9e4fcb);
        slider.maximumTrackTintColor = [UIColor whiteColor];
        slider.value = 1;
        [slider addTarget:self action:@selector(filterSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(filterSliderValueChangedEnd:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
        _filterStrengthSlider = slider;
        [_filterStrengthView addSubview:slider];
        
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40, 0, 20, 35.5)];
        rightLabel.textColor = [UIColor whiteColor];
        rightLabel.font = [UIFont systemFontOfSize:11];
        _filterStrength = rightLabel;
        [_filterStrengthView addSubview:rightLabel];
    }
    return _filterStrengthView;
}

- (UISlider *)beautySlider {
    if (!_beautySlider) {
        
        _beautySlider = [[STBeautySlider alloc] initWithFrame:CGRectMake(40, SCREEN_HEIGHT - 260 - 40, SCREEN_WIDTH - 90, 40)];
        _beautySlider.thumbTintColor = UIColorFromRGB(0x9e4fcb);
        _beautySlider.minimumTrackTintColor = UIColorFromRGB(0x9e4fcb);
        _beautySlider.maximumTrackTintColor = [UIColor whiteColor];
        _beautySlider.minimumValue = -1;
        _beautySlider.maximumValue = 1;
        _beautySlider.value = -1;
        _beautySlider.hidden = YES;
        _beautySlider.delegate = self;
        [_beautySlider addTarget:self action:@selector(beautySliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_beautySlider addTarget:self action:@selector(beautySliderValueChangedEnd:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    }
    return _beautySlider;
}

- (STViewButton *)specialEffectsBtn {
    if (!_specialEffectsBtn) {
        
        _specialEffectsBtn = [[[NSBundle mainBundle] loadNibNamed:@"STViewButton" owner:nil options:nil] firstObject];
        [_specialEffectsBtn setExclusiveTouch:YES];
        UIImage *image = [UIImage imageNamed:@"btn_special_effects.png"];
        _specialEffectsBtn.frame = CGRectMake([self layoutWidthWithValue:143], SCREEN_HEIGHT - 73.5, image.size.width, 50);
        //        _specialEffectsBtn.center = CGPointMake(_specialEffectsBtn.center.x, self.snapBtn.center.y);
        _specialEffectsBtn.backgroundColor = [UIColor clearColor];
        _specialEffectsBtn.imageView.image = [UIImage imageNamed:@"btn_special_effects.png"];
        _specialEffectsBtn.imageView.highlightedImage = [UIImage imageNamed:@"btn_special_effects_selected.png"];
        _specialEffectsBtn.titleLabel.textColor = [UIColor whiteColor];
        _specialEffectsBtn.titleLabel.highlightedTextColor = UIColorFromRGB(0xc086e5);
        _specialEffectsBtn.titleLabel.text = NSLocalizedString(@"特效", nil);
        _specialEffectsBtn.tag = STViewTagSpecialEffectsBtn;
        _specialEffectsBtn.hidden = YES;
    
        STWeakSelf;
        
        _specialEffectsBtn.tapBlock = ^{
            [weakSelf clickBottomViewButton:weakSelf.specialEffectsBtn];
        };
    }
    return _specialEffectsBtn;
}
- (STViewButton *)beautyBtn {
    if (!_beautyBtn) {
        _beautyBtn = [[[NSBundle mainBundle] loadNibNamed:@"STViewButton" owner:nil options:nil] firstObject];
        [_beautyBtn setExclusiveTouch:YES];
        UIImage *image = [UIImage imageNamed:@"btn_beauty.png"];
        _beautyBtn.frame = CGRectMake(SCREEN_WIDTH - [self layoutWidthWithValue:143] - image.size.width, SCREEN_HEIGHT - 73.5, image.size.width, 50);
        //        _beautyBtn.center = CGPointMake(_beautyBtn.center.x, self.snapBtn.center.y);
        _beautyBtn.backgroundColor = [UIColor clearColor];
        _beautyBtn.imageView.image = [UIImage imageNamed:@"btn_beauty.png"];
        _beautyBtn.imageView.highlightedImage = [UIImage imageNamed:@"btn_beauty_selected.png"];
        _beautyBtn.titleLabel.textColor = [UIColor whiteColor];
        _beautyBtn.titleLabel.highlightedTextColor = UIColorFromRGB(0xc086e5);
        _beautyBtn.titleLabel.text = NSLocalizedString(@"美颜", nil);
        _beautyBtn.tag = STViewTagBeautyBtn;
        _beautyBtn.hidden = YES;
        STWeakSelf;
        _beautyBtn.tapBlock = ^{
            [weakSelf clickBottomViewButton:weakSelf.beautyBtn];
        };
    }
    return _beautyBtn;
}
- (UIButton *)btnCompare {
    
    if (!_btnCompare) {
        
        _btnCompare = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnCompare.frame = CGRectMake(SCREEN_WIDTH - 80, SCREEN_HEIGHT - 150, 70, 35);
        [_btnCompare setTitle:NSLocalizedString(@"对比", nil) forState:UIControlStateNormal];
        [_btnCompare setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnCompare.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _btnCompare.layer.cornerRadius = 35 / 2.0;
        _btnCompare.hidden = YES;
//        [_btnCompare addTarget:self action:@selector(onBtnCompareTouchDown:) forControlEvents:UIControlEventTouchDown];
//        [_btnCompare addTarget:self action:@selector(onBtnCompareTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
//        [_btnCompare addTarget:self action:@selector(onBtnCompareTouchUpInside:) forControlEvents:UIControlEventTouchDragExit];
        
    }
    return _btnCompare;
}

- (STSlideView *)sliderView {
    if (!_sliderView) {
        _sliderView = [[[NSBundle mainBundle] loadNibNamed:@"STSlideView" owner:nil options:nil] firstObject];
        _sliderView.center = CGPointMake(-100, -100);
        _sliderView.hidden = YES;
        [_sliderView.makeupSlide addTarget:self action:@selector(makeupSlideAction:) forControlEvents:UIControlEventValueChanged];
        [_sliderView.filterSlide addTarget:self action:@selector(filterSlideAction:) forControlEvents:UIControlEventValueChanged];
        _sliderView.filterLabel.text = NSLocalizedString(@"美妆", nil);
        _sliderView.makeupLabel.text = NSLocalizedString(@"滤镜", nil);
    }
    return _sliderView;
}

- (STScrollTitleView *)scrollTitleView {
    if (!_scrollTitleView) {
        
        STWeakSelf;
        
        NSArray *stickerTypeArray = @[
//            @(STEffectsTypeStickerNew),
            @(STEffectsTypeSticker2D),
//            @(STEffectsTypeStickerAvatar),
            @(STEffectsTypeSticker3D),
            @(STEffectsTypeStickerGesture),
            @(STEffectsTypeStickerSegment),
//            @(STEffectsTypeStickerFaceDeformation),
//            @(STEffectsTypeStickerFaceChange),
//            @(STEffectsTypeStickerParticle),
//            @(STEffectsTypeObjectTrack),
//            @(STEffectsTypeStickerMy),
//#if DEBUG
//            @(STEffectsTypeStickerAdd),
//#endif
        ];
        NSArray *normalImages = @[
//            [UIImage imageNamed:@"new_sticker.png"],
            [UIImage imageNamed:@"2d.png"],
//            [UIImage imageNamed:@"avatar.png"],
            [UIImage imageNamed:@"3d.png"],
            [UIImage imageNamed:@"sticker_gesture.png"],
            [UIImage imageNamed:@"sticker_segment.png"],
//            [UIImage imageNamed:@"sticker_face_deformation.png"],
//            [UIImage imageNamed:@"face_painting.png"],
//            [UIImage imageNamed:@"particle_effect.png"],
//            [UIImage imageNamed:@"common_object_track.png"],
//            [UIImage imageNamed:@"native.png"],
//#if DEBUG
//            [UIImage imageNamed:@"native.png"],
//#endif
        ];
        NSArray *selectedImages = @[
//            [UIImage imageNamed:@"new_sticker_selected.png"],
            [UIImage imageNamed:@"2d_selected.png"],
//            [UIImage imageNamed:@"avatar_selected.png"],
            [UIImage imageNamed:@"3d_selected.png"],
            [UIImage imageNamed:@"sticker_gesture_selected.png"],
            [UIImage imageNamed:@"sticker_segment_selected.png"],
//            [UIImage imageNamed:@"sticker_face_deformation_selected.png"],
//            [UIImage imageNamed:@"face_painting_selected.png"],
//            [UIImage imageNamed:@"particle_effect_selected.png"],
//            [UIImage imageNamed:@"common_object_track_selected.png"],
//            [UIImage imageNamed:@"native_selected.png"],
//#if DEBUG
//            [UIImage imageNamed:@"native_selected.png"],
//#endif
        ];
        
        
        _scrollTitleView = [[STScrollTitleView alloc] initWithFrame:CGRectMake(57, 0, SCREEN_WIDTH - 57, 40) normalImages:normalImages selectedImages:selectedImages  effectsType:stickerTypeArray autoIndex:0 titleOnClick:^(STTitleViewItem *titleView, NSInteger index, STEffectsType type) {
            
            [weakSelf handleEffectsType:type];
        }];
        
        _scrollTitleView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _scrollTitleView;
}
- (STScrollTitleView *)beautyScrollTitleViewNew {
    if (!_beautyScrollTitleViewNew) {
        
        NSArray *beautyCategory = @[NSLocalizedString(@"整体效果", nil) ,
                                    NSLocalizedString(@"基础美颜", nil),
                                    NSLocalizedString(@"美形", nil),
                                    NSLocalizedString(@"微整形", nil),
                                    NSLocalizedString(@"美妆", nil),
                                    NSLocalizedString(@"滤镜", nil),
                                    NSLocalizedString(@"调整", nil)];
        NSArray *beautyType = @[@(STEffectsTypeBeautyWholeMakeup),
                                @(STEffectsTypeBeautyBase),
                                @(STEffectsTypeBeautyShape),
                                @(STEffectsTypeBeautyMicroSurgery),
                                @(STEffectsTypeBeautyMakeUp),
                                @(STEffectsTypeBeautyFilter),
                                @(STEffectsTypeBeautyAdjust)];
        
        STWeakSelf;
        _beautyScrollTitleViewNew = [[STScrollTitleView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40) titles:beautyCategory effectsType:beautyType autoIndex:0 titleOnClick:^(STTitleViewItem *titleView, NSInteger index, STEffectsType type) {
            [weakSelf handleEffectsType:type];
        }];
        _beautyScrollTitleViewNew.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _beautyScrollTitleViewNew;
}


#pragma mark - lazy load array

- (NSArray *)arrObjectTrackers {
    if (!_arrObjectTrackers) {
        _arrObjectTrackers = [self getObjectTrackModels];
    }
    return _arrObjectTrackers;
}

- (NSArray *)getObjectTrackModels {
    
    NSMutableArray *arrModels = [NSMutableArray array];
    
    NSArray *arrImageNames = @[@"object_track_happy", @"object_track_hi", @"object_track_love", @"object_track_star", @"object_track_sticker", @"object_track_sun"];
    
    for (int i = 0; i < arrImageNames.count; ++i) {
        
        STCollectionViewDisplayModel *model = [[STCollectionViewDisplayModel alloc] init];
        model.strPath = NULL;
        model.strName = @"";
        model.index = i;
        model.isSelected = NO;
        model.image = [UIImage imageNamed:arrImageNames[i]];
        model.modelType = STEffectsTypeObjectTrack;
        
        [arrModels addObject:model];
    }
    
    return [arrModels copy];
}

- (NSMutableArray *)arrBeautyViews {
    if (!_arrBeautyViews) {
        _arrBeautyViews = [NSMutableArray array];
    }
    return _arrBeautyViews;
}

- (NSMutableArray *)arrFilterCategoryViews {
    
    if (!_arrFilterCategoryViews) {
        
        _arrFilterCategoryViews = [NSMutableArray array];
    }
    return _arrFilterCategoryViews;
}

- (CGFloat)layoutWidthWithValue:(CGFloat)value {
    
    return (value / 750) * SCREEN_WIDTH;
}

- (CGFloat)layoutHeightWithValue:(CGFloat)value {
    
    return (value / 1334) * SCREEN_HEIGHT;
}

- (BOOL)checkMediaStatus:(NSString *)mediaType {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    BOOL res;
    
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            res = NO;
            break;
        case AVAuthorizationStatusAuthorized:
            res = YES;
            break;
    }
    return res;
}

- (UIButton *)resetBtn {
    if (!_resetBtn) {
        
        _resetBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, SCREEN_HEIGHT - 50, 100, 30)];
        _resetBtn.center = CGPointMake(_resetBtn.center.x, self.beautyBtn.center.y);
        
        [_resetBtn setImage:[UIImage imageNamed:@"reset"] forState:UIControlStateNormal];
        [_resetBtn setTitle:NSLocalizedString(@"重置", nil)  forState:UIControlStateNormal];
        _resetBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_resetBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [_resetBtn addTarget:self action:@selector(resetBeautyValues:) forControlEvents:UIControlEventTouchUpInside];
        
        _resetBtn.hidden = YES;
    }
    return _resetBtn;
}

- (void)beautyContainerViewAppear {
    
    if (self.coreStateMangement.curEffectBeautyType == self.beautyCollectionView.selectedModel.modelType && [self isMemberOfClass:[UIViewController class]]) {
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

- (STTriggerView *)triggerView {
    if (!_triggerView) {
        _triggerView = [[STTriggerView alloc] init];
    }
    return _triggerView;
}

#pragma mark - UI Actions
/// 滤镜改变
/// @param model 滤镜model
/// @param flag 是否清零
- (void)manuHandleFilter{
    if (self.coreStateMangement.curEffectBeautyType != STEffectsTypeBeautyWholeMakeup) {
        if(self.isWholeMakeUp) self.isWholeMakeUp = false;
        /// MARK: YLPLAT-12538
        self.currentModel = nil;
        [self resetWholeMakeupUIs];
        [self.beautyCollectionView reloadData];
    }
}
- (void)handleFilterChanged:(STCollectionViewDisplayModel *)model zeroFlag:(BOOL)flag {
    self.coreStateMangement.filterModel = model;
    self.bFilter = model.index > 0;
    if (self.bFilter && !flag) {
        self.filterStrengthView.hidden = NO;
    } else {
        self.filterStrengthView.hidden = YES;
    }
    if ([self isMemberOfClass:[UIViewController class]]) {
        [[STDefaultSetting sharedInstace] updateLastParamsCurType:self.coreStateMangement.curEffectBeautyType
                                                 wholeEffectModel:self.coreStateMangement.currentWholeMakeUpModel
                                                        baseModel:self.currentModel
                                                           filter:self.coreStateMangement.filterModel
                                                           makeup:nil
                                                    needWriteFile:NO];
    }
    //update filters value
    [self calculateModelValue:model.value];
    // MARK: YLPLAT-12536
    self.filterStrength.text = [NSString stringWithFormat:@"%2d", (int)roundf(model.value * 100)];
    self.filterStrengthSlider.value = model.value;
}

- (void)calculateModelValue:(float)value{
    NSArray *models = @[self.filterView.filterCollectionView.arrPortraitFilterModels,
                        self.filterView.filterCollectionView.arrSceneryFilterModels,
                        self.filterView.filterCollectionView.arrStillLifeFilterModels,
                        self.filterView.filterCollectionView.arrDeliciousFoodFilterModels];
    for(NSArray<STCollectionViewDisplayModel *> *array in models){
        for(STCollectionViewDisplayModel *model in array){
            model.value = value;
        }
    }
}

- (void)handleFilterChanged:(STCollectionViewDisplayModel *)model {
    [self handleFilterChanged:model zeroFlag:NO];
}

- (void)clickBottomViewButton:(STViewButton *)senderView {
    //    NSLog(@"%s", __func__);
}

- (void)handleEffectsType:(STEffectsType)type{
    //    NSLog(@"%s", __func__);
    [self updateBeautySliderValue:self.beautyCollectionView.selectedModel];
}

- (void)resetFilterValue:(float)value arrays:(NSArray<STCollectionViewDisplayModel *> *)array{
    for(STCollectionViewDisplayModel *model in array){
        model.value = value;
    }
}

/// 滤镜分类选中
/// @param recognizer tap
- (void)switchFilterType:(UITapGestureRecognizer *)recognizer {
    
    [UIView animateWithDuration:0.5 animations:^{
        self.filterCategoryView.frame = CGRectMake(-SCREEN_WIDTH, self.filterCategoryView.frame.origin.y, SCREEN_WIDTH, 300);
        self.filterView.frame = CGRectMake(0, self.filterView.frame.origin.y, SCREEN_WIDTH, 300);
    }];
    
    if (self.coreStateMangement.filterModel.modelType == recognizer.view.tag && self.coreStateMangement.filterModel.isSelected) {
        self.filterStrengthView.hidden = NO;
    } else {
        self.filterStrengthView.hidden = YES;
    }
    
    //    self.filterStrengthView.hidden = !(self.coreStateMangement.filterModel.modelType == recognizer.view.tag);
    
    switch (recognizer.view.tag) {
            
        case STEffectsTypeFilterPortrait:
            _filterView.leftView.imageView.image = [UIImage imageNamed:@"portrait_highlighted"];
            _filterView.leftView.titleLabel.text = NSLocalizedString(@"人物", nil);
            _filterView.filterCollectionView.arrModels = _filterView.filterCollectionView.arrPortraitFilterModels;
            break;
            
        case STEffectsTypeFilterScenery:
            _filterView.leftView.imageView.image = [UIImage imageNamed:@"scenery_highlighted"];
            _filterView.leftView.titleLabel.text = NSLocalizedString(@"风景", nil);
            _filterView.filterCollectionView.arrModels = _filterView.filterCollectionView.arrSceneryFilterModels;
            break;
            
        case STEffectsTypeFilterStillLife:
            _filterView.leftView.imageView.image = [UIImage imageNamed:@"still_life_highlighted"];
            _filterView.leftView.titleLabel.text = NSLocalizedString(@"静物", nil);
            _filterView.filterCollectionView.arrModels = _filterView.filterCollectionView.arrStillLifeFilterModels;
            break;
            
        case STEffectsTypeFilterDeliciousFood:
            _filterView.leftView.imageView.image = [UIImage imageNamed:@"delicious_food_highlighted"];
            _filterView.leftView.titleLabel.text = NSLocalizedString(@"美食", nil);
            _filterView.filterCollectionView.arrModels = _filterView.filterCollectionView.arrDeliciousFoodFilterModels;
            break;
            
        default:
            break;
    }
    [self resetFilterValue:self.coreStateMangement.filterModel.value arrays:_filterView.filterCollectionView.arrModels];
    [_filterView.filterCollectionView reloadData];
}

/// 切换贴纸
/// @param model 贴纸model
// MARK: 切换贴纸
- (void)handleStickerChanged:(EffectsCollectionViewCellModel *)model {
    self.coreStateMangement.prepareModel = model;
    
    if (STEffectsTypeStickerMy == model.iEffetsType) {
        [self setMaterialModel:model];
        return;
    }
    STWeakSelf;
    BOOL isMaterialExist = [[EFMaterialDownloadStatusManager sharedInstance] efDownloadStatus:model.NewMaterial];
    BOOL isDirectory = YES;

    BOOL isFileAvalible = [[NSFileManager defaultManager] fileExistsAtPath:model.NewMaterial.efMaterialPath
                                                               isDirectory:&isDirectory];
    if (isMaterialExist && (isDirectory || !isFileAvalible)) {

        model.state = NotDownloaded;
        model.strMaterialPath = nil;
        isMaterialExist = NO;
    }
    
    if (model && model.NewMaterial && !isMaterialExist) {
        
        model.state = IsDownloading;
        [self.effectsList reloadData];
        [[EFMaterialDownloadStatusManager sharedInstance] efStartDownload:model.NewMaterial onProgress:^(id<EFDataSourcing> material, float fProgress, int64_t iSize) {
            
                } onSuccess:^(id<EFDataSourcing> material) {
                                model.state = Downloaded;
                                model.strMaterialPath = material.efMaterialPath;
                    
                                if (model == weakSelf.coreStateMangement.prepareModel) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                    
                                        [weakSelf setMaterialModel:model];
                                    });
                    
                                }else{
                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                    
                                        [weakSelf.effectsList reloadData];
                                    });
                                }
                } onFailure:^(id<EFDataSourcing> material, int iErrorCode, NSString *strMessage) {
                    
                    NSLog(@"下载失败: [PLST] Error Id : %d Message : %@",iErrorCode,strMessage);
                }];

    }else{
        [self setMaterialModel:model];
    }
}
- (void)setMaterialModel:(EffectsCollectionViewCellModel *)targetModel{}

- (void)handleBeautyTypeChanged:(STNewBeautyCollectionViewModel *)model { // 整体效果 - 滤镜选择
    _currentModel = model;
    if (model.modelType == STEffectsTypeBeautyWholeMakeup) {
        self.coreStateMangement.currentWholeMakeUpModel = model;
        [STDefaultSetting sharedInstace].wholeEffectsIndex = model.modelIndex;
    }
    if ([self isMemberOfClass:[UIViewController class]]) {
        [[STDefaultSetting sharedInstace] updateLastParamsCurType:self.coreStateMangement.curEffectBeautyType
                                                 wholeEffectModel:self.coreStateMangement.currentWholeMakeUpModel
                                                        baseModel:self.currentModel
                                                           filter:self.coreStateMangement.filterModel
                                                           makeup:nil
                                                    needWriteFile:NO];
    }
    
    float preType  = self.curBeautyBeautyType;
    float preValue = self.beautySlider.value;
    float curValue = -2;
    float lblVal = -2;
    
    self.curBeautyBeautyType = model.beautyType;
    
    self.beautySlider.hidden = NO;
    
    switch (model.beautyType) {
        case STBeautyTypeNone:
        case STBeautyTypeMakeupZBYuanQi:
        case STBeautyTypeMakeupZBZiRan:
        case STBeautyTypeMakeupZPYuanQi:
        case STBeautyTypeMakeupZPZiRan:
        case STBeautyTypeMakeupZBYuanHua:
        case STBeautyTypeMakeupZhigan:
        case STBeautyTypeMakeupRedwine:
        case STBeautyTypeMakeupSweet:
        case STBeautyTypeMakeupWestern:
        case STBeautyTypeMakeupWhitetea:
        case STBeautyTypeMakeupDeep:
        case STBeautyTypeMakeupTianran:
        case STBeautyTypeMakeupSweetgirl:
        case STBeautyTypeMakeupOxygen:
        case STBeautyTypeMakeupNvshen:{
            self.sliderView.hidden = NO;
            self.beautySlider.hidden = YES;
            [self resetBmpModels];
            [self setWholeMakeUpParam:model.beautyType];
            [self resetMakeup:model.beautyType];
            [self resetFilter:model.beautyType];
            self.isWholeMakeUp = true;
            break;
        }
        case STBeautyTypeWhiten1:
        case STBeautyTypeWhiten2:
        case STBeautyTypeWhiten3:
        case STBeautyTypeRuddy:
        case STBeautyTypeDermabrasion1:
        case STBeautyTypeDermabrasion2:
        case STBeautyTypeDehighlight:
        case STBeautyTypeShrinkFace:
        case STBeautyTypeEnlargeEyes:
        case STBeautyTypeShrinkJaw:
        case STBeautyTypeThinFaceShape:
        case STBeautyTypeNarrowNose:
        case STBeautyTypeContrast:
        case STBeautyTypeClarity:
        case STBeautyTypeSharpen:
        case STBeautyTypeSaturation:
        case STBeautyTypeNarrowFace:
        case STBeautyTypeHead:
        case STBeautyTypeRoundEye:
        case STBeautyTypeAppleMusle:
        case STBeautyTypeProfileRhinoplasty:
        case STBeautyTypeBrightEye:
        case STBeautyTypeRemoveDarkCircles:
        case STBeautyTypeWhiteTeeth:
        case STBeautyTypeShrinkCheekbone:
        case STBeautyTypeOpenCanthus:
        case STBeautyTypeRemoveNasolabialFolds:
        case STBeautyTypeOpenExternalCanthusRatio:
            curValue = model.beautyValue / 50.0 - 1;
            lblVal = (curValue + 1) * 50.0;
            break;
        case STBeautyTypeChin:
        case STBeautyTypeHairLine:
        case STBeautyTypeLengthNose:
        case STBeautyTypeMouthSize:
        case STBeautyTypeLengthPhiltrum:
        case STBeautyTypeEyeAngle:
        case STBeautyTypeEyeDistance:
            curValue = model.beautyValue / 100.0;
            lblVal = curValue * 100.0;
            break;
    }
    
    if (model.beautyType == STBeautyTypeWhiten1  &&
        (self.baseBeautyModels[1].beautyValue > 0 ||
         self.baseBeautyModels[2].beautyValue > 0)) {
        [[UIApplication sharedApplication].keyWindow makeToast:@"请先美白2和美白3调整为0"];
        model.selected = NO;
        self.beautySlider.hidden = YES;
        [self.beautyCollectionView reloadData];
        return;
    }else if(model.beautyType == STBeautyTypeWhiten2  &&
             (self.baseBeautyModels[0].beautyValue > 0 ||
              self.baseBeautyModels[2].beautyValue > 0)){
        [[UIApplication sharedApplication].keyWindow makeToast:@"请先美白1和美白3调整为0"];
        model.selected = NO;
        self.beautySlider.hidden = YES;
        [self.beautyCollectionView reloadData];
        return;
    }else if(model.beautyType == STBeautyTypeWhiten3  &&
             (self.baseBeautyModels[0].beautyValue > 0 ||
              self.baseBeautyModels[1].beautyValue > 0)){
        [[UIApplication sharedApplication].keyWindow makeToast:@"请先美白1和美白2调整为0"];
        model.selected = NO;
        self.beautySlider.hidden = YES;
        [self.beautyCollectionView reloadData];
        return;
    }
    
    if (model.beautyType == STBeautyTypeDermabrasion1 && self.baseBeautyModels[5].beautyValue > 0) {
        [[UIApplication sharedApplication].keyWindow makeToast:@"请先磨皮2调整为0"];
        model.selected = NO;
        self.beautySlider.hidden = YES;
        [self.beautyCollectionView reloadData];
        return;
    }else if(model.beautyType == STBeautyTypeDermabrasion2 && self.baseBeautyModels[4].beautyValue > 0){
        [[UIApplication sharedApplication].keyWindow makeToast:@"请先磨皮1调整为0"];
        model.selected = NO;
        self.beautySlider.hidden = YES;
        [self.beautyCollectionView reloadData];
        return;
    }
    
    switch (model.beautyType) {
        case STBeautyTypeDermabrasion1:
            [self.effectManager setBeautifyMode:1 type:EFFECT_BEAUTY_BASE_FACE_SMOOTH];
            break;
        case STBeautyTypeDermabrasion2:
            [self.effectManager setBeautifyMode:2 type:EFFECT_BEAUTY_BASE_FACE_SMOOTH];
            break;
        default:
            break;
    }
    
    if (curValue == preValue && preType != model.beautyType) {
        if (lblVal > 9.9 && lblVal < 10.0) {
            lblVal = 10;
        }
        self.beautySlider.valueLabel.text = [NSString stringWithFormat:@"%d", (int)lblVal];
    }
    self.beautySlider.value = curValue;
    [self setBeautyParamsWithType:model];
}


- (void)resetBasebeautySharpMicAd:(STNewBeautyCollectionViewModel *)model { // 整体效果 - 滤镜选择
    if ([self isMemberOfClass:[UIViewController class]]) {
        [[STDefaultSetting sharedInstace] updateLastParamsCurType:self.coreStateMangement.curEffectBeautyType
                                                 wholeEffectModel:self.coreStateMangement.currentWholeMakeUpModel
                                                        baseModel:self.currentModel
                                                           filter:self.coreStateMangement.filterModel
                                                            // MARK: YLPLAT-12489
                                                           makeup:self.curSelMakeUps
                                                    needWriteFile:NO];
    }
    self.beautySlider.hidden = YES;
    [self setBeautyParams];
    [self.beautyCollectionView reloadData];
}

-(void)updateBeautySliderValue:(STNewBeautyCollectionViewModel *)model{
    float curValue = -2;
    float lblVal = -2;
    switch (model.beautyType) {
        case STBeautyTypeWhiten1:
        case STBeautyTypeWhiten2:
        case STBeautyTypeWhiten3:
        case STBeautyTypeRuddy:
        case STBeautyTypeDermabrasion1:
        case STBeautyTypeDermabrasion2:
        case STBeautyTypeDehighlight:
        case STBeautyTypeShrinkFace:
        case STBeautyTypeEnlargeEyes:
        case STBeautyTypeShrinkJaw:
        case STBeautyTypeThinFaceShape:
        case STBeautyTypeNarrowNose:
        case STBeautyTypeContrast:
        case STBeautyTypeClarity:
        case STBeautyTypeSharpen:
        case STBeautyTypeSaturation:
        case STBeautyTypeNarrowFace:
        case STBeautyTypeHead:
        case STBeautyTypeRoundEye:
        case STBeautyTypeAppleMusle:
        case STBeautyTypeProfileRhinoplasty:
        case STBeautyTypeBrightEye:
        case STBeautyTypeRemoveDarkCircles:
        case STBeautyTypeWhiteTeeth:
        case STBeautyTypeShrinkCheekbone:
        case STBeautyTypeOpenCanthus:
        case STBeautyTypeRemoveNasolabialFolds:
        case STBeautyTypeOpenExternalCanthusRatio:
            curValue = model.beautyValue / 50.0 - 1;
            lblVal = (curValue + 1) * 50.0;
            break;
        case STBeautyTypeChin:
        case STBeautyTypeHairLine:
        case STBeautyTypeLengthNose:
        case STBeautyTypeMouthSize:
        case STBeautyTypeLengthPhiltrum:
        case STBeautyTypeEyeAngle:
        case STBeautyTypeEyeDistance:
            curValue = model.beautyValue / 100.0;
            lblVal = curValue * 100.0;
            break;
    }
    self.beautySlider.valueLabel.text = [NSString stringWithFormat:@"%d", (int)lblVal];
    self.beautySlider.value = curValue;
}

- (void)showTrigleAction:(uint64_t)iAction{
    
    NSString *triggerContent = @"";
    UIImage *image = nil;
    
    if (0 != iAction) {//有 trigger信息
        
        if (CHECK_FLAG(iAction, ST_MOBILE_BROW_JUMP)) {
            triggerContent = NSLocalizedString(@"请挑挑眉", nil);
            image = [UIImage imageNamed:@"head_brow_jump"];
        }
        if (CHECK_FLAG(iAction, ST_MOBILE_EYE_BLINK)) {
            triggerContent = NSLocalizedString(@"请眨眨眼", nil);
            image = [UIImage imageNamed:@"eye_blink"];
        }
        if (CHECK_FLAG(iAction, ST_MOBILE_HEAD_YAW)) {
            triggerContent = NSLocalizedString(@"请摇摇头", nil);
            image = [UIImage imageNamed:@"head_yaw"];
        }
        if (CHECK_FLAG(iAction, ST_MOBILE_HEAD_PITCH)) {
            triggerContent = NSLocalizedString(@"请点点头", nil);
            image = [UIImage imageNamed:@"head_pitch"];
        }
        if (CHECK_FLAG(iAction, ST_MOBILE_MOUTH_AH)) {
            triggerContent = NSLocalizedString(@"请张张嘴", nil);
            image = [UIImage imageNamed:@"mouth_ah"];
        }
        if (CHECK_FLAG(iAction, ST_MOBILE_HAND_GOOD)) {
            triggerContent = NSLocalizedString(@"请比个赞", nil);
            image = [UIImage imageNamed:@"hand_good"];
        }
        if (CHECK_FLAG(iAction, ST_MOBILE_HAND_PALM)) {
            triggerContent = NSLocalizedString(@"请伸手掌", nil);
            image = [UIImage imageNamed:@"hand_palm"];
        }
        if (CHECK_FLAG(iAction, ST_MOBILE_HAND_LOVE)) {
            triggerContent = NSLocalizedString(@"请双手比心", nil);
            image = [UIImage imageNamed:@"hand_love"];
        }
        if (CHECK_FLAG(iAction, ST_MOBILE_HAND_HOLDUP)) {
            triggerContent = NSLocalizedString(@"请托个手", nil);
            image = [UIImage imageNamed:@"hand_holdup"];
        }
        if (CHECK_FLAG(iAction, ST_MOBILE_HAND_CONGRATULATE)) {
            triggerContent = NSLocalizedString(@"请抱个拳", nil);
            image = [UIImage imageNamed:@"hand_congratulate"];
        }
        if (CHECK_FLAG(iAction, ST_MOBILE_HAND_FINGER_HEART)) {
            triggerContent = NSLocalizedString(@"请单手比心", nil);
            image = [UIImage imageNamed:@"hand_finger_heart"];
        }
        if (CHECK_FLAG(iAction, ST_MOBILE_HAND_FINGER_INDEX)) {
            triggerContent = NSLocalizedString(@"请伸出食指", nil);
            image = [UIImage imageNamed:@"hand_finger"];
        }
        if (CHECK_FLAG(iAction, ST_MOBILE_HAND_OK)) {
            triggerContent = NSLocalizedString(@"请亮出OK手势", nil);
            image = [UIImage imageNamed:@"hand_ok"];
        }
        if (CHECK_FLAG(iAction, ST_MOBILE_HAND_SCISSOR)) {
            triggerContent = NSLocalizedString(@"请比个剪刀手", nil);
            image = [UIImage imageNamed:@"hand_victory"];
        }
        if (CHECK_FLAG(iAction, ST_MOBILE_HAND_PISTOL)) {
            triggerContent = NSLocalizedString(@"请比个手枪", nil);
            image = [UIImage imageNamed:@"hand_gun"];
        }
        
        if (CHECK_FLAG(iAction, ST_MOBILE_HAND_666)) {
            triggerContent = NSLocalizedString(@"请亮出666手势", nil);
            image = [UIImage imageNamed:@"666_selected"];
        }
        if (CHECK_FLAG(iAction, ST_MOBILE_HAND_BLESS)) {
            triggerContent = NSLocalizedString(@"请双手合十", nil);
            image = [UIImage imageNamed:@"bless_selected"];
        }
        if (CHECK_FLAG(iAction, ST_MOBILE_HAND_ILOVEYOU)) {
            triggerContent = NSLocalizedString(@"请亮出我爱你手势", nil);
            image = [UIImage imageNamed:@"love_selected"];
        }
        if (CHECK_FLAG(iAction, ST_MOBILE_HAND_FIST)) {
            triggerContent = NSLocalizedString(@"请举起拳头", nil);
            image = [UIImage imageNamed:@"fist_selected"];
        }
        if (CHECK_FLAG(iAction, ST_MOBILE_FACE_LIPS_POUTED)) {
            triggerContent = NSLocalizedString(@"请嘟嘴", nil);
            image = [UIImage imageNamed:@"FACE_LIPS_POUTED"];
        }
        if (CHECK_FLAG(iAction, ST_MOBILE_FACE_LIPS_UPWARD)) {
            triggerContent = NSLocalizedString(@"请笑一笑", nil);
            image = [UIImage imageNamed:@"FACE_LIPS_UPWARD"];
        }
        [self.triggerView showTriggerViewWithContent:triggerContent image:image];
    }
}

-(void)zeroBmp {
    //update UI
    self.bmpStrenghView.hidden = YES;
    [self.bmpColView zeroMakeUp];
    //update effect
    [self.beautyCollectionView reloadData];
    [self clearMakeups];
}

- (void)resetBmp {
    [self resetBmpModels];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resetUIs" object:nil];
}

- (void)resetBmpModels{
//         _bmp_Eye_Value = _bmp_EyeLiner_Value = _bmp_EyeLash_Value = _bmp_Lip_Value = _bmp_Brow_Value = _bmp_Nose_Value = _bmp_EyeShadow_Value = _bmp_Blush_Value = _bmp_Eyeball_Value = _bmp_Maskhair_Value = _bmp_WholeMakeUp_Value = 0.8;
}

#pragma mark 重置美颜参数
- (void)resetBeautyValues:(UIButton *)sender {
    switch (self.coreStateMangement.curEffectBeautyType) {
        case STEffectsTypeBeautyWholeMakeup:{
            //get get the default model
            [self resetWholeMakeupUIs];
            for(STNewBeautyCollectionViewModel *model in self.wholeMakeUpModels){
                if (model.beautyType == STBeautyTypeMakeupNvshen) {
                    model.selected = YES;
                    [self handleBeautyTypeChanged:model];
                }
            }
            self.beautyCollectionView.models = self.wholeMakeUpModels;
            [self.beautyCollectionView reloadData];
        }
            break;
        case STEffectsTypeBeautyBase:
        case STEffectsTypeBeautyShape:
        case STEffectsTypeBeautyMicroSurgery:
        case STEffectsTypeBeautyAdjust:
            // MARK: YLPLAT-12503
            [[STDefaultSetting sharedInstace] zeroMakeupWithHandle:_hEffectHandle withType:self.coreStateMangement.curEffectBeautyType];
            [[STDefaultSetting sharedInstace] resetBeautyParamsWithType:self.coreStateMangement.curEffectBeautyType];
            for(STNewBeautyCollectionViewModel *model in self.beautyCollectionView.models){
                if (model.selected) {
                    [self updateBeautySliderValue:model];
                    break;
                }
            }
            [self resetBasebeautySharpMicAd:_currentModel];
            break;
        case STEffectsTypeBeautyMakeUp:
            [self.bmpColView wholeMakeUp:STBeautyTypeMakeupNvshen];
            self.bmpStrenghView.hidden = YES;
            break;
        case STEffectsTypeBeautyFilter:{
            NSString *name = @"nvshen";
            STCollectionViewDisplayModel *model =  self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:name]];
            model.value = 0.85;
            [self updateFilterViewDiselectFilter:@"innate" selectFilter:name];
            self.filterStrengthView.hidden = YES;
        }
            break;
        default:
            break;
    }
    [self.beautyCollectionView reloadData];
}

- (void)setWholeMakeUpParam:(STBeautyType)beautyType {
    self.needRestoreWholeEffect = YES;
    STCollectionViewDisplayModel *model =  self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:@"native"]];
    model.value = 0.8;
    if (beautyType == STBeautyTypeMakeupZBYuanQi) {
        //美妆
        [self.bmpColView wholeMakeUp:beautyType];
        //滤镜
        STCollectionViewDisplayModel *model =  self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:@"native"]];
        model.value = 0.85;
        [self updateFilterViewDiselectFilter:@"innate" selectFilter:@"native"];
    }else if (beautyType == STBeautyTypeMakeupZBZiRan) {
        //美妆
        [self.bmpColView wholeMakeUp:beautyType];
        //滤镜
        STCollectionViewDisplayModel *model =  self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:@"snow"]];
        model.value = 0.85;
        [self updateFilterViewDiselectFilter:@"innate" selectFilter:@"snow"];
    }else if (beautyType == STBeautyTypeMakeupZPYuanQi) {
        //美妆
        [self.bmpColView wholeMakeUp:beautyType];
        
        //滤镜
        STCollectionViewDisplayModel *model =  self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:@"native"]];
        model.value = 0.85;
        [self updateFilterViewDiselectFilter:@"innate" selectFilter:@"native"];
    }else if (beautyType == STBeautyTypeMakeupZBYuanHua) {
        //美妆
        [self.bmpColView wholeMakeUp:beautyType];
        
        //滤镜
        STCollectionViewDisplayModel *model =  self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:@"ziranguang"]];
        model.value = 0.85;
        [self updateFilterViewDiselectFilter:@"innate" selectFilter:@"ziranguang"];
    }else if(beautyType == STBeautyTypeMakeupZPZiRan){
        //美妆
        [self.bmpColView wholeMakeUp:beautyType];
        
        //滤镜
        STCollectionViewDisplayModel *model =  self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:@"native"]];
        model.value = 0.85;
        [self updateFilterViewDiselectFilter:@"innate" selectFilter:@"native"];
    }else if(beautyType == STBeautyTypeMakeupNvshen    ||
             beautyType == STBeautyTypeMakeupWhitetea   ||
             beautyType == STBeautyTypeMakeupRedwine    ||
             beautyType == STBeautyTypeMakeupZhigan     ||
             beautyType == STBeautyTypeMakeupSweet      ||
             beautyType == STBeautyTypeMakeupWestern    ||
             beautyType == STBeautyTypeMakeupDeep       ||
             beautyType == STBeautyTypeMakeupTianran    ||
             beautyType == STBeautyTypeMakeupOxygen     ||
             beautyType == STBeautyTypeMakeupSweetgirl){
        //美妆
        [self.bmpColView wholeMakeUp:beautyType];
        
        //滤镜
        NSString *name = @"nvshen";
        
        STCollectionViewDisplayModel *model =  self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:name]];
        model.value = 0.85;
        
        if (beautyType == STBeautyTypeMakeupWhitetea) {
            name = @"whitetea";
            STCollectionViewDisplayModel *model =  self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:name]];
            model.value = 0.85;
        }
        
        if (beautyType == STBeautyTypeMakeupZhigan) {
            name = @"pinzhi";
            STCollectionViewDisplayModel *model =  self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:name]];
            model.value = 0.85;
        }
        
        if (beautyType == STBeautyTypeMakeupRedwine) {
            name  = @"redwhine";
            STCollectionViewDisplayModel *model =  self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:name]];
            model.value = 0.85;
        }
        
        if (beautyType == STBeautyTypeMakeupSweet) {
            name = @"sweet";
            STCollectionViewDisplayModel *model =  self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:name]];
            model.value = 0.85;
        }
        
        if (beautyType == STBeautyTypeMakeupWestern) {
            name = @"sweetheart";
            STCollectionViewDisplayModel *model =  self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:name]];
            model.value = 0.85;
        }
        
        if (beautyType == STBeautyTypeMakeupDeep) {
            name = @"deep";
            STCollectionViewDisplayModel *model =  self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:name]];
            model.value = 0.85;
        }
        
        if (beautyType == STBeautyTypeMakeupTianran) {
            name = @"tianran";
            STCollectionViewDisplayModel *model =  self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:name]];
            model.value = 0.85;
        }
        
        if (beautyType == STBeautyTypeMakeupSweetgirl) {
            name = @"sweetgirl";
            STCollectionViewDisplayModel *model =  self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:name]];
            model.value = 0.85;
        }
        
        if (beautyType == STBeautyTypeMakeupOxygen) {
            name = @"oxygen";
            STCollectionViewDisplayModel *model =  self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:name]];
            model.value = 0.85;
        }
        
        if (beautyType == STBeautyTypeMakeupNvshen) {
            STCollectionViewDisplayModel *model =  self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:name]];
            model.value = 0.85;
        }
        [self updateFilterViewDiselectFilter:@"innate" selectFilter:name];
    }
    
    self.filterStrength.text = [NSString stringWithFormat:@"%2d", (int)(model.value * 100)];
    self.filterStrengthSlider.value = model.value;
    self.filterStrengthView.hidden = YES;
    self.bmpStrenghView.hidden = YES;
}

- (void)recoverSelectedWholeMakeup {
    [self.beautyCollectionView reloadData];
}

- (void)diselectedWholeMakeup {
    [self resetWholeMakeupUIs];
    [self.beautyCollectionView reloadData];
}

- (void)updateFilterViewDiselectFilter:(NSString *)deselctfilter
                          selectFilter:(NSString *)selectfilter{
    [self handleFilterChanged:self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:selectfilter]]];
    self.filterView.filterCollectionView.arrModels = self.filterView.filterCollectionView.arrPortraitFilterModels;
    [self.filterView reload];
    //清空之前的
    self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:deselctfilter]].isSelected = false;
    [self.filterView.filterCollectionView deselectItemAtIndexPath:[NSIndexPath indexPathForRow:[self getBabyPinkFilterIndex:deselctfilter] inSection:0]  animated:true];
    //设置现在的
    self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex:selectfilter]].isSelected = true;
    [self.filterView.filterCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:[self getBabyPinkFilterIndex:selectfilter] inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

//get Filter model accord model.name
- (NSUInteger)getBabyPinkFilterIndex:(NSString *)name {
    
    __block NSUInteger index = 0;
    
    [self.filterView.filterCollectionView.arrModels enumerateObjectsUsingBlock:^(STCollectionViewDisplayModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.strName isEqualToString:name]) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

- (NSUInteger)getBabyPinkFilterIndex {
    
    __block NSUInteger index = 0;
    
    [_filterView.filterCollectionView.arrPortraitFilterModels enumerateObjectsUsingBlock:^(STCollectionViewDisplayModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.strName isEqualToString:@"innate"]) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

- (void)resetWholeMakeupUIs{
    for (int i = 0;i < self.wholeMakeUpModels.count; i++) {
        STNewBeautyCollectionViewModel *model = self.wholeMakeUpModels[i];
        if (model.selected) {
            model.selected = !model.selected;
        }
    }
}

#pragma mark - handle make up begin
- (void)updateBmpValue:(STBMPTYPE)type value:(float)value{
    switch (type) {
        case STBMPTYPE_WHOLEMAKEUP:
            for(STMakeupDataModel *model in [STDefaultSetting sharedInstace].m_wholeMakeArr){
                model.m_bmpStrength = value;
            }
            break;
        case STBMPTYPE_EYE_LINER:
            for(STMakeupDataModel *model in [STDefaultSetting sharedInstace].m_eyelinerArr){
                model.m_bmpStrength = value;
            }
            break;
        case STBMPTYPE_EYE_LASH:
            for(STMakeupDataModel *model in [STDefaultSetting sharedInstace].m_eyelashArr){
                model.m_bmpStrength = value;
            }
            break;
        case STBMPTYPE_LIP:
            for(STMakeupDataModel *model in [STDefaultSetting sharedInstace].m_lipsArr){
                model.m_bmpStrength = value;
            }
            break;
        case STBMPTYPE_EYE_BROW:
            for(STMakeupDataModel *model in [STDefaultSetting sharedInstace].m_browsArr){
                model.m_bmpStrength = value;
            }
            break;
        case STBMPTYPE_NOSE:
            for(STMakeupDataModel *model in [STDefaultSetting sharedInstace].m_noseArr){
                model.m_bmpStrength = value;
            }
            break;
        case STBMPTYPE_CHEEK:
            for(STMakeupDataModel *model in [STDefaultSetting sharedInstace].m_cheekArr){
                model.m_bmpStrength = value;
            }
            break;
        case STBMPTYPE_EYE_BALL:
            for(STMakeupDataModel *model in [STDefaultSetting sharedInstace].m_eyeballArr){
                model.m_bmpStrength = value;
            }
            break;
        case STBMPTYPE_EYE_SHADOW:
            for(STMakeupDataModel *model in [STDefaultSetting sharedInstace].m_eyeshadowArr){
                model.m_bmpStrength = value;
            }
            break;
        case STBMPTYPE_MASKHAIR:
            for(STMakeupDataModel *model in [STDefaultSetting sharedInstace].m_maskhairArr){
                model.m_bmpStrength = value;
            }
            return;
        default:
            break;
    }
}

- (void)sliderValueDidChange:(float)value{
//    if (!_hEffectHandle) {
//        return;
//    }
    if (self.isWholeMakeUp) {
        self.isWholeMakeUp = false;
        [self resetWholeMakeupUIs];
    }
    st_effect_beauty_type_t makeupType = 0;
    makeupType = [self getMakeUpType:_bmp_Current_Model.m_bmpType];
    [self updateBmpValue:_bmp_Current_Model.m_bmpType value:value];
    switch (_bmp_Current_Model.m_bmpType) {
        case STBMPTYPE_WHOLEMAKEUP:
            _bmp_WholeMakeUp_Model.m_bmpStrength = value;
            break;
        case STBMPTYPE_EYE_LINER:
            _bmp_EyeLiner_Model.m_bmpStrength = value;
            break;
        case STBMPTYPE_EYE_LASH:
            _bmp_EyeLash_Model.m_bmpStrength = value;
            break;
        case STBMPTYPE_LIP:
            _bmp_Lip_Model.m_bmpStrength = value;
            break;
        case STBMPTYPE_EYE_BROW:
            _bmp_Brow_Model.m_bmpStrength = value;
            break;
        case STBMPTYPE_NOSE:
            _bmp_Nose_Model.m_bmpStrength = value;
            break;
        case STBMPTYPE_CHEEK:
            _bmp_Cheek_Model.m_bmpStrength = value;
            break;
        case STBMPTYPE_EYE_BALL:
            _bmp_Eyeball_Model.m_bmpStrength = value;
            break;
        case STBMPTYPE_EYE_SHADOW:
            _bmp_EyeShadow_Model.m_bmpStrength = value;
            break;
        case STBMPTYPE_MASKHAIR:
            _bmp_Maskhair_Model.m_bmpStrength = value;
            [self.bmpStrenghView updateSliderValue:value];
            [self.effectManager updateBeautify:Threshold_1_2_22(value) type:makeupType];
            return;
        default:
            break;
    }
    [self.bmpStrenghView updateSliderValue:value];
    [self.effectManager updateBeautify:value type:makeupType];
}

- (void)sliderValueDidChangeEnd:(float)value{
    if ([self isMemberOfClass:[UIViewController class]]) {
        [[STDefaultSetting sharedInstace] updateLastParamsCurType:self.coreStateMangement.curEffectBeautyType
                                                 wholeEffectModel:self.coreStateMangement.currentWholeMakeUpModel
                                                        baseModel:self.currentModel
                                                           filter:self.coreStateMangement.filterModel
                                                           makeup:nil
                                                    needWriteFile:NO];
    }
}

- (void)cleanMakeUp{
//    if (_hEffectHandle) {
        [[STDefaultSetting sharedInstace] zeroMakeupWithHandle:_hEffectHandle withType:STEffectsTypeBeautyWholeMakeup];
//    }
}

- (void)showBmpStrengthView:(NSArray<STMakeupDataModel *> *)array{
    BOOL show = NO;
    for(STMakeupDataModel *model in array){
        show = model.m_selected;
        if (show) {
            // MARK: YLPLAT-12487
            self.bmpStrenghView.hidden = ([model.m_name isEqualToString:@"None"] | [model.m_name isEqualToString:@"none"]) ? YES : !show;
            [self.bmpStrenghView updateSliderValue:model.m_bmpStrength];
            break;
        }
    }
}

- (void)didSelectedCellModel:(STMakeupDataModel *)model{
    switch (model.m_bmpType) {
        case STBMPTYPE_MASKHAIR:
            [self showBmpStrengthView:[STDefaultSetting sharedInstace].m_maskhairArr];
            return;
        case STBMPTYPE_LIP:
            [self showBmpStrengthView:[STDefaultSetting sharedInstace].m_lipsArr];
            break;
        case STBMPTYPE_CHEEK:
            [self showBmpStrengthView:[STDefaultSetting sharedInstace].m_cheekArr];
            break;
        case STBMPTYPE_NOSE:
            [self showBmpStrengthView:[STDefaultSetting sharedInstace].m_noseArr];
            break;
        case STBMPTYPE_EYE_BROW:
            [self showBmpStrengthView:[STDefaultSetting sharedInstace].m_browsArr];
            break;
        case STBMPTYPE_EYE_LINER:
            [self showBmpStrengthView:[STDefaultSetting sharedInstace].m_eyelinerArr];
            break;
        case STBMPTYPE_EYE_LASH:
            [self showBmpStrengthView:[STDefaultSetting sharedInstace].m_eyelashArr];
            break;
        case STBMPTYPE_EYE_BALL:
            [self showBmpStrengthView:[STDefaultSetting sharedInstace].m_eyeballArr];
            break;
        case STBMPTYPE_EYE_SHADOW:
            [self showBmpStrengthView:[STDefaultSetting sharedInstace].m_eyeshadowArr];
            break;
        case STBMPTYPE_WHOLEMAKEUP:
            [self showBmpStrengthView:[STDefaultSetting sharedInstace].m_wholeMakeArr];
            if (_bmp_WholeMakeUp_Model.m_selected) {
                self.bmpStrenghView.hidden = NO;
            }
            break;
        default:
            break;
    }
}

- (void)clearMakeups{
    // MARK: YLPLAT-12589
    for(int i = EFFECT_BEAUTY_MAKEUP_HAIR_DYE; i <= EFFECT_BEAUTY_MAKEUP_PACKED; i++){
        [self.effectManager setBeautify:NULL type:i];
    }
}

- (void)didSelectedModelByManu{
    if (self.coreStateMangement.curEffectBeautyType != STEffectsTypeBeautyWholeMakeup) {
        if(self.isWholeMakeUp) self.isWholeMakeUp = false;
        // MARK: YLPLAT-12488
        self.currentModel = nil;
        [self resetWholeMakeupUIs];
        [self.beautyCollectionView reloadData];
        [STDefaultSetting sharedInstace].wholeEffectsIndex = -1;
    }
    
    self.needRestoreWholeEffect = NO;
}

- (void)didSelectedDetailModel:(STMakeupDataModel *)model
{
    if (_beforeStickerSelMakeUps.count) {
        [_beforeStickerSelMakeUps removeAllObjects];
    }
    
    if (self.curType == STCurrentTypeWholeEffect) {
        if (_beforeStickerSelMakeUps.count) {
            [_beforeStickerSelMakeUps removeAllObjects];
        }
    }else{
        if(![_selMakeUpsOther containsObject:model]){
            [_selMakeUpsOther addObject:model];
        }
    }
    _bmp_Current_Model = model;
    st_effect_beauty_type_t makeupType = [self getMakeUpType:model.m_bmpType];
    if (!model.m_selected) {
        self.bmpStrenghView.hidden = YES;
        [self.effectManager setBeautify:NULL type:makeupType];
        [self.effectManager updateBeautify:0.0 type:makeupType];
    }else{
        if (self.beautyContainerViewIsShow) {
            // MARK: YLPLAT-12487
            self.bmpStrenghView.hidden = [model.m_name isEqualToString:@"None"] | [model.m_name isEqualToString:@"none"] | (_coreStateMangement.curEffectBeautyType == STEffectsTypeBeautyWholeMakeup);
        }
    }
    if (_bmp_Pre_Model.m_bmpType != STBMPTYPE_WHOLEMAKEUP &&
        _bmp_Current_Model.m_bmpType == STBMPTYPE_WHOLEMAKEUP) {
        //clear makeups
        [self clearMakeups];
    }
    // MARK: YLPLAT-12573
    if (model.m_selected) {
        if (model.m_zipPath) {
            [self.effectManager setBeautify:model.m_zipPath type:makeupType];
            [self updateBmp:model type:makeupType];
        }else{
            [self.effectManager setBeautify:NULL type:makeupType];
        }
        _bmp_Pre_Model = _bmp_Current_Model;
        unsigned long long config = 0;
        config = [self.effectManager getEffectDetectConfig];
        if (config != 0) {
            _makeUpConf = config;
        }
    }
    if ([self isMemberOfClass:[UIViewController class]]) {
        [[STDefaultSetting sharedInstace] updateLastParamsCurType:self.coreStateMangement.curEffectBeautyType
                                                 wholeEffectModel:self.coreStateMangement.currentWholeMakeUpModel
                                                        baseModel:self.currentModel
                                                           filter:self.coreStateMangement.filterModel
                                                           makeup:nil
                                                    needWriteFile:NO];
    }
}

- (void)updateMakeupValues:(float)value array:(NSArray<STMakeupDataModel *> *)array{
    for(STMakeupDataModel *model in array){
        model.m_bmpStrength = value;
    }
}

- (void)updateBmp:(STMakeupDataModel *)model type:(st_effect_beauty_type_t)makeupType{
    switch (model.m_bmpType) {
        case STBMPTYPE_MASKHAIR:
            _bmp_Maskhair_Model = model;
            [self updateMakeupValues:model.m_bmpStrength array:self.m_maskhairArr];
            [self.bmpStrenghView updateSliderValue:model.m_bmpStrength];
            [self.effectManager updateBeautify:Threshold_1_2_22(model.m_bmpStrength) type:makeupType];
            return;
        case STBMPTYPE_LIP:
            [self updateMakeupValues:model.m_bmpStrength array:self.m_lipsArr];
            _bmp_Lip_Model = model;
            break;
        case STBMPTYPE_CHEEK:
            [self updateMakeupValues:model.m_bmpStrength array:self.m_cheekArr];
            _bmp_Cheek_Model = model;
            break;
        case STBMPTYPE_NOSE:
            [self updateMakeupValues:model.m_bmpStrength array:self.m_noseArr];
            _bmp_Nose_Model = model;
            break;
        case STBMPTYPE_EYE_BROW:
            [self updateMakeupValues:model.m_bmpStrength array:self.m_browsArr];
            _bmp_Brow_Model = model;
            break;
        case STBMPTYPE_EYE_LINER:
            [self updateMakeupValues:model.m_bmpStrength array:self.m_eyelinerArr];
            _bmp_EyeLiner_Model = model;
            break;
        case STBMPTYPE_EYE_LASH:
            [self updateMakeupValues:model.m_bmpStrength array:self.m_eyelashArr];
            _bmp_EyeLash_Model = model;
            break;
        case STBMPTYPE_EYE_BALL:
            [self updateMakeupValues:model.m_bmpStrength array:self.m_eyeballArr];
            _bmp_Eyeball_Model = model;
            break;
        case STBMPTYPE_EYE_SHADOW:
            [self updateMakeupValues:model.m_bmpStrength array:self.m_eyeshadowArr];
            _bmp_EyeShadow_Model = model;
            break;
        case STBMPTYPE_WHOLEMAKEUP:
            [self updateMakeupValues:model.m_bmpStrength array:self.m_wholeMakeArr];
            _bmp_WholeMakeUp_Model = model;
            break;
        default:
            break;
    }
    [self.bmpStrenghView updateSliderValue:model.m_bmpStrength];
    [self.effectManager updateBeautify:model.m_bmpStrength type:makeupType];
}

- (void)updateValue:(STMakeupDataModel *)model currentValue:(float)value{
    switch (model.m_bmpType) {
        case STBMPTYPE_EYE_LINER:
            model.m_bmpStrength = value;
            break;
        case STBMPTYPE_EYE_LASH:
            model.m_bmpStrength = value;
            break;
        case STBMPTYPE_LIP:
            model.m_bmpStrength = value;
            break;
        case STBMPTYPE_EYE_BROW:
            model.m_bmpStrength = value;
            break;
        case STBMPTYPE_NOSE:
            model.m_bmpStrength = value;
            break;
        case STBMPTYPE_EYE_BALL:
            model.m_bmpStrength = value;
            break;
        case STBMPTYPE_MASKHAIR:
            model.m_bmpStrength = value;
            break;
        case STBMPTYPE_CHEEK:
            model.m_bmpStrength = value;
            break;
        case STBMPTYPE_WHOLEMAKEUP:{
            float temp = [self scaleWholeMake];
            model.m_bmpStrength = value * temp;
        }
        default:
            break;
    }
    [self updateBmpValue:model.m_bmpType value:model.m_bmpStrength];
    //更新自拍自然 自拍元气 直播自然 直播元气 直播原画美妆效果
    if (self.curBeautyBeautyType == STBeautyTypeMakeupZPZiRan) {
        _bmp_Lip_Model.m_bmpStrength = value * 0.4;
        _bmp_Nose_Model.m_bmpStrength = value * 0.58;
        [self updateBmpValue:_bmp_Lip_Model.m_bmpType value:_bmp_Lip_Model.m_bmpStrength];
        [self updateBmpValue:_bmp_Lip_Model.m_bmpType value:_bmp_Lip_Model.m_bmpStrength];
    }
    
    if (self.curBeautyBeautyType == STBeautyTypeMakeupZPYuanQi) {
        _bmp_Lip_Model.m_bmpStrength = value * 0.25;
        _bmp_Brow_Model.m_bmpStrength = value * 0.15;
        _bmp_Cheek_Model.m_bmpStrength = value * 0.4;
        [self updateBmpValue:_bmp_Lip_Model.m_bmpType value:_bmp_Lip_Model.m_bmpStrength];
        [self updateBmpValue:_bmp_Brow_Model.m_bmpType value:_bmp_Brow_Model.m_bmpStrength];
        [self updateBmpValue:_bmp_Cheek_Model.m_bmpType value:_bmp_Cheek_Model.m_bmpStrength];
    }
    
    if (self.curBeautyBeautyType == STBeautyTypeMakeupZBZiRan) {
        _bmp_Lip_Model.m_bmpStrength = value * 0.25;
        _bmp_Brow_Model.m_bmpStrength = value * 0.15;
        _bmp_Cheek_Model.m_bmpStrength = value * 0.23;
        [self updateBmpValue:_bmp_Lip_Model.m_bmpType value:_bmp_Lip_Model.m_bmpStrength];
        [self updateBmpValue:_bmp_Brow_Model.m_bmpType value:_bmp_Brow_Model.m_bmpStrength];
        [self updateBmpValue:_bmp_Cheek_Model.m_bmpType value:_bmp_Cheek_Model.m_bmpStrength];
    }
    
    if (self.curBeautyBeautyType == STBeautyTypeMakeupZBYuanQi) {
        _bmp_Lip_Model.m_bmpStrength = value * 0.54;
        _bmp_Brow_Model.m_bmpStrength = value * 0.2;
        _bmp_EyeLash_Model.m_bmpStrength = value * 0.4;
        _bmp_EyeShadow_Model.m_bmpStrength = value * 0.8;
        [self updateBmpValue:_bmp_Lip_Model.m_bmpType value:_bmp_Lip_Model.m_bmpStrength];
        [self updateBmpValue:_bmp_Brow_Model.m_bmpType value:_bmp_Brow_Model.m_bmpStrength];
        [self updateBmpValue:_bmp_EyeLash_Model.m_bmpType value:_bmp_EyeLash_Model.m_bmpStrength];
        [self updateBmpValue:_bmp_EyeShadow_Model.m_bmpType value:_bmp_EyeShadow_Model.m_bmpStrength];
    }
}

- (float)scaleWholeMake{
    switch(_currentModel.beautyType){
        case STBeautyTypeMakeupZhigan:
        case STBeautyTypeMakeupRedwine:
        case STBeautyTypeMakeupSweet:
        case STBeautyTypeMakeupWhitetea:
            return 0.8;
        case STBeautyTypeMakeupWestern:
            return 0.6;
        case STBeautyTypeMakeupNvshen:
        case STBeautyTypeMakeupDeep:
            return 1.0;
        default:
            return 1.0;
    }
}

- (void)updateWholemakeup:(STMakeupDataModel *)model currentValue:(float)value{
    [self updateValue:model currentValue:value];
    [self updateBmpValueAndUI:model];
}

- (void)updateBmpValueAndUI:(STMakeupDataModel *)model{
    st_effect_beauty_type_t makeupType = [self getMakeUpType:model.m_bmpType];
    switch (model.m_bmpType) {
        case STBMPTYPE_MASKHAIR:
            [self.bmpStrenghView updateSliderValue:model.m_bmpStrength];
            [self.effectManager updateBeautify:Threshold_1_2_22(model.m_bmpStrength) type:makeupType];
            break;
        default:
            [self.bmpStrenghView updateSliderValue:model.m_bmpStrength];
            [self.effectManager updateBeautify: model.m_bmpStrength type:makeupType];
            break;
    }
    [self processImageAndDisplay];
}

- (void)backToMainView
{
    self.bmpStrenghView.hidden = YES;
}

- (st_effect_beauty_type_t)getMakeUpType:(STBMPTYPE)bmpType
{
    st_effect_beauty_type_t type;
    switch (bmpType) {
        case STBMPTYPE_EYE_LINER:
            type = EFFECT_BEAUTY_MAKEUP_EYE_LINE;
            break;
        case STBMPTYPE_EYE_LASH:
            type = EFFECT_BEAUTY_MAKEUP_EYE_LASH;
            break;
        case STBMPTYPE_LIP:
            type = EFFECT_BEAUTY_MAKEUP_LIP;
            break;
        case STBMPTYPE_EYE_BROW:
            type = EFFECT_BEAUTY_MAKEUP_EYE_BROW;
            break;
        case STBMPTYPE_NOSE:
            type = EFFECT_BEAUTY_MAKEUP_NOSE;
            break;
        case STBMPTYPE_EYE_BALL:
            type = EFFECT_BEAUTY_MAKEUP_EYE_BALL;
            break;
        case STBMPTYPE_MASKHAIR:
            type = EFFECT_BEAUTY_MAKEUP_HAIR_DYE;
            break;
        case STBMPTYPE_EYE_SHADOW:
            type = EFFECT_BEAUTY_MAKEUP_EYE_SHADOW;
            break;
        case STBMPTYPE_CHEEK:
            type = EFFECT_BEAUTY_MAKEUP_CHEEK;
            break;
        case STBMPTYPE_WHOLEMAKEUP:
            type = EFFECT_BEAUTY_MAKEUP_PACKED;
            break;
        default:
            break;
    }
    
    return type;
}

#pragma handle make up end

- (void)processImageAndDisplay{}


#pragma mark - STBeautySliderDelegate
- (CGFloat)currentSliderValue:(float)value slider:(UISlider *)slider {
    
    switch (self.curBeautyBeautyType) {
            
        case STBeautyTypeNone:
        case STBeautyTypeWhiten1:
        case STBeautyTypeWhiten2:
        case STBeautyTypeWhiten3:
        case STBeautyTypeRuddy:
        case STBeautyTypeDermabrasion1:
        case STBeautyTypeDermabrasion2:
        case STBeautyTypeDehighlight:
        case STBeautyTypeShrinkFace:
        case STBeautyTypeEnlargeEyes:
        case STBeautyTypeShrinkJaw:
        case STBeautyTypeThinFaceShape:
        case STBeautyTypeNarrowNose:
        case STBeautyTypeContrast:
        case STBeautyTypeClarity:
        case STBeautyTypeSaturation:
        case STBeautyTypeSharpen:
        case STBeautyTypeNarrowFace:
        case STBeautyTypeHead:
        case STBeautyTypeRoundEye:
        case STBeautyTypeAppleMusle:
        case STBeautyTypeProfileRhinoplasty:
        case STBeautyTypeBrightEye:
        case STBeautyTypeRemoveDarkCircles:
        case STBeautyTypeWhiteTeeth:
        case STBeautyTypeShrinkCheekbone:
        case STBeautyTypeOpenCanthus:
        case STBeautyTypeOpenExternalCanthusRatio:
        case STBeautyTypeRemoveNasolabialFolds:
            value = (value + 1) / 2.0;
            break;
        default:
            break;
    }
    return value;
}

- (void)zeroFilter{
    for(STCollectionViewDisplayModel *model in self.filterView.filterCollectionView.arrModels){
        model.value = 0.0;
        model.isSelected = NO;
    }
    self.coreStateMangement.filterModel.isSelected = NO;
    [self handleFilterChanged:self.coreStateMangement.filterModel zeroFlag:YES];
    self.coreStateMangement.filterModel = nil;
}

- (void)refreshFilterCategoryState:(STEffectsType)type {
    //cleare
    for (int i = 0; i < self.arrFilterCategoryViews.count; ++i) {
        if (self.arrFilterCategoryViews[i].highlighted) {
            self.arrFilterCategoryViews[i].highlighted = NO;
        }
    }
    
}
- (void)beautySliderValueChanged:(UISlider *)sender {
    
    //[-1,1] -> [0,1]
    float value1 = (sender.value + 1) / 2;
    //[-1,1]
    float value2 = sender.value;
    
    //get current selected model
    STNewBeautyCollectionViewModel *curSelModel = nil;
    for(STNewBeautyCollectionViewModel *model in self.beautyCollectionView.models){
        if (model.selected) curSelModel = model;
    }
    
    switch (curSelModel.beautyType) {
        case STBeautyTypeNone:
            break;
        case STBeautyTypeWhiten1:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeWhiten2:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeWhiten3:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeRuddy:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeDermabrasion1:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeDermabrasion2:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeDehighlight:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeShrinkFace:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeNarrowFace:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeRoundEye:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeEnlargeEyes:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeShrinkJaw:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeHead:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeThinFaceShape:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeChin:
            curSelModel.beautyValue = [STConvert floatToInt:(value2 * 100)];
            break;
        case STBeautyTypeHairLine:
            curSelModel.beautyValue = [STConvert floatToInt:(value2 * 100)];
            break;
        case STBeautyTypeNarrowNose:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeLengthNose:
            curSelModel.beautyValue = [STConvert floatToInt:(value2 * 100)];
            break;
        case STBeautyTypeMouthSize:
            curSelModel.beautyValue = [STConvert floatToInt:(value2 * 100)];
            break;
        case STBeautyTypeLengthPhiltrum:
            curSelModel.beautyValue = [STConvert floatToInt:(value2 * 100)];
            break;
        case STBeautyTypeContrast:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeClarity:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeSaturation:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeSharpen:
            _currentModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeAppleMusle:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeProfileRhinoplasty:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeBrightEye:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeRemoveDarkCircles:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeWhiteTeeth:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeShrinkCheekbone:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeEyeDistance:
            curSelModel.beautyValue = [STConvert floatToInt:(value2 * 100)];
            break;
        case STBeautyTypeEyeAngle:
            curSelModel.beautyValue = [STConvert floatToInt:(value2 * 100)];
            break;
        case STBeautyTypeOpenCanthus:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeOpenExternalCanthusRatio:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
        case STBeautyTypeRemoveNasolabialFolds:
            curSelModel.beautyValue = [STConvert floatToInt:(value1 * 100)];
            break;
    }
    
    //update data Source
    [[STDefaultSetting sharedInstace] updateCurrentBeautyValue:curSelModel];
    [self setBeautyParams];
    [self.beautyCollectionView reloadData];
}

- (void)beautySliderValueChangedEnd:(UISlider *)slider{
    //update last makeup material value and save value to the Plist
    if ([self isMemberOfClass:[UIViewController class]]) {
        [[STDefaultSetting sharedInstace] updateLastParamsCurType:self.coreStateMangement.curEffectBeautyType
                                                 wholeEffectModel:self.coreStateMangement.currentWholeMakeUpModel
                                                        baseModel:self.currentModel
                                                           filter:self.coreStateMangement.filterModel
                                                           makeup:nil
                                                    needWriteFile:NO];
    }
}

- (void)filterSliderValueChanged:(UISlider *)sender {
    self.coreStateMangement.filterModel.value = sender.value;
    self.filterStrength.text = [NSString stringWithFormat:@"%d", (int)(sender.value * 100)];
    [self.effectManager updateBeautify:sender.value type:EFFECT_BEAUTY_FILTER];
    
}

- (void)filterSliderValueChangedEnd:(UISlider *)sender{
    //update last makeup material value and save value to the Plist
    if ([self isMemberOfClass:[UIViewController class]]) {
        [[STDefaultSetting sharedInstace] updateLastParamsCurType:self.coreStateMangement.curEffectBeautyType
                                                 wholeEffectModel:self.coreStateMangement.currentWholeMakeUpModel
                                                        baseModel:self.currentModel
                                                           filter:self.coreStateMangement.filterModel
                                                           makeup:nil
                                                    needWriteFile:NO];
    }
    //update whole filter value
    for(STCollectionViewDisplayModel *model in self.filterView.filterCollectionView.arrModels){
        model.value = sender.value;
    }
}

#pragma mark - STSliderView Action
- (void)makeupSlideAction:(UISlider *)slider { // 美妆强度slider改变
    self.sliderView.makeupValue.text = [NSString stringWithFormat:@"%.0f", slider.value];
    if (self.bmpColView.BMPCollectionViewBlock) {
        //update makeups
        self.bmpColView.BMPCollectionViewBlock(slider.value/100);
    }
    [STDefaultSetting sharedInstace].iWholeMakeUpValue = roundf(slider.value);
}

- (void)resetMakeup:(STBeautyType)type{
    self.sliderView.makeupSlide.value = 85;
    self.sliderView.makeupValue.text = @"85";
    [STDefaultSetting sharedInstace].iWholeMakeUpValue = 85;
}

- (void)filterSlideAction:(UISlider *)slider { // 滤镜slider改变
    float filterValue = [self filter:self.curBeautyBeautyType valueFrom:slider.value] / 100;
    NSLog(@"%f", filterValue);
    _filterStrengthSlider.value = filterValue;
    _filterStrength.text = [NSString stringWithFormat:@"%.0f", filterValue * 100];
    self.sliderView.filterValue.text = [NSString stringWithFormat:@"%.0f", slider.value];
    self.coreStateMangement.filterModel.value = filterValue;
    if ([self isMemberOfClass:[UIViewController class]]) {
        [[STDefaultSetting sharedInstace] updateLastParamsCurType:self.coreStateMangement.curEffectBeautyType
                                                 wholeEffectModel:self.coreStateMangement.currentWholeMakeUpModel
                                                        baseModel:self.currentModel
                                                           filter:self.coreStateMangement.filterModel
                                                           makeup:nil
                                                    needWriteFile:NO];
    }
    [self.effectManager updateBeautify:filterValue type:EFFECT_BEAUTY_FILTER];
    // MARK: YLPLAT-12536
    [STDefaultSetting sharedInstace].iWholeFilterValue = roundf(slider.value);
}

- (void)resetFilter:(STBeautyType)type{
    self.sliderView.filterSlide.value = 85;
    self.sliderView.filterValue.text = @"85";
    
    int value = [self filter:type valueFrom:self.sliderView.filterSlide.value];
    
    _filterStrengthSlider.value = value / 100.0;
    _filterStrength.text = [NSString stringWithFormat:@"%d", value];
    [self.effectManager updateBeautify:value/100.0 type:EFFECT_BEAUTY_FILTER];
    [STDefaultSetting sharedInstace].iWholeFilterValue = 85;
}

/// 根据整体效果的美颜类型以及整体效果中滤镜的值来计算滤镜的强度
/// @param type 整体效果
/// @param wholeFilterValue 整体效果的滤镜 强度
-(CGFloat)filter:(STBeautyType)type valueFrom:(CGFloat)wholeFilterValue {
    CGFloat value = (type == STBeautyTypeMakeupRedwine) || (type == STBeautyTypeMakeupWhitetea) || (type == STBeautyTypeMakeupSweet) ? 85 * wholeFilterValue / 100 : 100 * wholeFilterValue / 100;
    if (type == STBeautyTypeMakeupWestern) {
        value = 60 * wholeFilterValue / 100;
    }
    
    if (type == STBeautyTypeMakeupZPZiRan) {
        value = 60 * wholeFilterValue / 100;
    }
    
    if (type == STBeautyTypeMakeupZPYuanQi) {
        value = 91 * wholeFilterValue / 100;
    }
    
    if (type == STBeautyTypeMakeupZBZiRan) {
        value = 52 * wholeFilterValue / 100;
    }
    
    if (type == STBeautyTypeMakeupZBYuanQi) {
        value = 80 * wholeFilterValue / 100;
    }
    return value;
}

- (void)getBeautyParam:(BOOL)add{
    if (add > 0) {
        //cache last beauty/filter/makeup state
        if ([self isMemberOfClass:[UIViewController class]]) {
            [[STDefaultSetting sharedInstace] updateLastParamsCurType:self.coreStateMangement.curEffectBeautyType
                                                     wholeEffectModel:self.coreStateMangement.currentWholeMakeUpModel
                                                            baseModel:self.currentModel
                                                               filter:self.coreStateMangement.filterModel
                                                               makeup:nil
                                                        needWriteFile:NO];
        }

        //如果当前是整体效果
        BOOL selected = NO;
        for(STNewBeautyCollectionViewModel *model in self.wholeMakeUpModels){
            selected |= model.selected;
        }
        if (selected) {
            self.curType = STCurrentTypeWholeEffect;
        }else{
            self.curType = STCurrentTypeOther;
        }
        
        //cleare wholemake UI
        // MARK: YLPLAT-12470
        STWeakSelf;
        _overlap_callback_block = ^(BOOL has4xx, BOOL has5xx) {
            STStrongSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (has4xx || has5xx) {
                    strongSelf.bRestored = NO;
                    [strongSelf diselectedWholeMakeup];
                }
                if (has4xx) {
                    //makeup
                    [strongSelf deSelectMakup];
                }
                if (has5xx) {
                    //filter
                    [strongSelf deSelectFilter];
                }
                
            });
            _overlap_callback_block = nil;
        };
        
    }else{
        //多个贴纸的取消
        if(self.coreStateMangement.addedStickerArray.count && self.addSticker){
            STWeakSelf;
            _overlap_callback_block = ^(BOOL has4xx, BOOL has5xx) {
                STStrongSelf;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!has4xx && !has5xx) {
                        [strongSelf restoreStickerStateBeayManu:NO];
                    }
                });
                weakSelf.overlap_callback_block = nil;
            };
        }else{
            //单个贴纸取消
            STWeakSelf;
            _overlap_callback_block = ^(BOOL has4xx, BOOL has5xx) {
                STStrongSelf;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!has4xx && !has5xx) {
                        [strongSelf restoreStickerStateBeayManu:NO];
                    }
                });
                weakSelf.overlap_callback_block = nil;
            };
        }
    }
    [self.beautyCollectionView reloadData];
}

- (void)restoreStickerStateBeayManu:(BOOL)bManu{
    if (!self.bRestored) {
        self.bRestored = YES;
        //恢复美妆
        [self selectMakeup];
        //恢复滤镜
        [self selectFilter];
        //恢复美颜参数
        [[STDefaultSetting sharedInstace] restoreBeforeStickerParametersMenu:bManu];
        //恢复效果
        [self setBeautyParams];
        self.filterStrengthView.hidden = YES;
        //restore 整体效果
        BOOL filterCtr = self.preFilterModel == self.coreStateMangement.filterModel;
        if (_needRestoreWholeEffect && filterCtr) {
            self.coreStateMangement.currentWholeMakeUpModel.selected = YES;
            [self recoverSelectedWholeMakeup];
        }
        self.preFilterModel = NULL;
    }
}

- (void)selectFilter{
    //restore UIs
    if (self.coreStateMangement.filterModel) {
        self.coreStateMangement.filterModel.isSelected = YES;
        [self handleFilterChanged:self.coreStateMangement.filterModel];
    }
}

- (void)deSelectFilter{
    self.preFilterModel = self.coreStateMangement.filterModel;
    self.coreStateMangement.filterModel.isSelected = NO;
    for(int i = 0; i < self.arrFilterCategoryViews.count; i++){
        self.arrFilterCategoryViews[i].highlighted = NO;
    }
}

- (void)selectMakeup{
    if (self.curType == STCurrentTypeWholeEffect) {
        [self selectMakeupWithType:STCurrentTypeWholeEffect];
    }else{
        [self selectMakeupWithType:STCurrentTypeOther];
    }
}

- (void)selectMakeupWithType:(STCurrentType)type{
    NSArray * sets = nil;
    if(type == STCurrentTypeWholeEffect){
        [self getBeforeAddStickerSelectedMakeup];
        sets = [NSArray arrayWithArray:self.beforeStickerSelMakeUps];
    }else{
        sets = [NSArray arrayWithArray:self.selMakeUpsOther];
    }
    if (sets.count == 0) { return; }
    for(STMakeupDataModel *model in sets){
        model.m_selected = YES;
    }
    NSSet *set = [NSSet setWithArray:sets];
    [self.bmpColView.m_bmpDetailColV restorePreSelectedMakeUps:set];
    self.beforeStickerSelMakeUps = nil;
    self.selMakeUpsOther = nil;
}

- (void)deSelectMakup{
    //update makeup UIs
    [self.bmpColView resetUis];
    [self getBeforeAddStickerSelectedMakeup];
    for(STMakeupDataModel *model in _beforeStickerSelMakeUps){
        model.m_selected = NO;
    }
    [self.bmpColView.m_bmpDetailColV reload];
    //clear make up
    [self clearMakeups];
}

- (void)getBeforeAddStickerSelectedMakeup{
    if (_beforeStickerSelMakeUps.count) {
        return;
    }
    NSMutableArray *ret = [NSMutableArray array];
    if(_bmp_Lip_Model.m_selected)           [ret addObject:_bmp_Lip_Model];
    if(_bmp_Brow_Model.m_selected)          [ret addObject:_bmp_Brow_Model];
    if(_bmp_WholeMakeUp_Model.m_selected)   [ret addObject:_bmp_WholeMakeUp_Model];
    if(_bmp_EyeLiner_Model.m_selected)      [ret addObject:_bmp_EyeLiner_Model];
    if(_bmp_EyeLash_Model.m_selected)       [ret addObject:_bmp_EyeLash_Model];
    if(_bmp_Nose_Model.m_selected)          [ret addObject:_bmp_Nose_Model];
    if(_bmp_Blush_Model.m_selected)         [ret addObject:_bmp_Blush_Model];
    if(_bmp_Cheek_Model.m_selected)         [ret addObject:_bmp_Cheek_Model];
    if(_bmp_Eyeball_Model.m_selected)       [ret addObject:_bmp_Eyeball_Model];
    if(_bmp_Maskhair_Model.m_selected)      [ret addObject:_bmp_Maskhair_Model];
    if(_bmp_EyeShadow_Model.m_selected)     [ret addObject:_bmp_EyeShadow_Model];
    if (!_beforeStickerSelMakeUps || !_beforeStickerSelMakeUps.count) _beforeStickerSelMakeUps = [NSMutableArray arrayWithArray:ret];
    self.selMakeUpsOther = [NSMutableArray arrayWithArray:_beforeStickerSelMakeUps];
}

- (NSMutableSet *)getSelectedMakeUps{
    NSMutableSet *curSelMakeUps = [NSMutableSet set];
    if (_beforeStickerSelMakeUps) {
        curSelMakeUps = [NSMutableSet setWithArray:_beforeStickerSelMakeUps];
        return curSelMakeUps;
    }
    if(_bmp_Lip_Model.m_selected)           [curSelMakeUps addObject:_bmp_Lip_Model];
    if(_bmp_Brow_Model.m_selected)          [curSelMakeUps addObject:_bmp_Brow_Model];
    if(_bmp_WholeMakeUp_Model.m_selected)   [curSelMakeUps addObject:_bmp_WholeMakeUp_Model];
    if(_bmp_EyeLiner_Model.m_selected)      [curSelMakeUps addObject:_bmp_EyeLiner_Model];
    if(_bmp_EyeLash_Model.m_selected)       [curSelMakeUps addObject:_bmp_EyeLash_Model];
    if(_bmp_Nose_Model.m_selected)          [curSelMakeUps addObject:_bmp_Nose_Model];
    if(_bmp_Blush_Model.m_selected)         [curSelMakeUps addObject:_bmp_Blush_Model];
    if(_bmp_Cheek_Model.m_selected)         [curSelMakeUps addObject:_bmp_Cheek_Model];
    if(_bmp_Eyeball_Model.m_selected)       [curSelMakeUps addObject:_bmp_Eyeball_Model];
    if(_bmp_Maskhair_Model.m_selected)      [curSelMakeUps addObject:_bmp_Maskhair_Model];
    if(_bmp_EyeShadow_Model.m_selected)     [curSelMakeUps addObject:_bmp_EyeShadow_Model];
    return curSelMakeUps;
}

- (void)getUIConfigFromDisk{
    //从内存中取出
    [[STDefaultSetting sharedInstace] getDefaultValueFromDisk];
    STEffectsType type = [STDefaultSetting sharedInstace].scrollType;
    switch (type) {
        case STEffectsTypeBeautyFilter:
        case STEffectsTypeBeautyMakeUp:{
                [self selectFilterFromDiskWithValue:YES];
                [self selectMakeupFromDiskWithValue:YES];
            }
            break;
        case STEffectsTypeBeautyWholeMakeup:
            //这里有互斥关系
            [self selectFilterFromDiskWithValue:YES];
            [self selectMakeupFromDiskWithValue:YES];
            [self selectBeautyFromDiskWithType:type];
            [self selectWholeEffectsFromDisk];
            break;
        default:
            //这里没有互斥关系
            [self selectBeautyFromDiskWithType:type];
            [self selectFilterFromDiskWithValue:YES];
            [self selectMakeupFromDiskWithValue:YES];
            [self selectWholeEffectsFromDisk];
            break;
    
    }
    int index  = (int)[_beautyScrollTitleViewNew.arrEffectsType indexOfObject:@(type)];
    //scroll title update
    [_beautyScrollTitleViewNew setSelectedIndex:index>=0?index:0 animated:YES];
}

- (BOOL)selectWholeEffectsFromDisk{
    int wholeEffectsIndex = [STDefaultSetting sharedInstace].wholeEffectsIndex;
    if (wholeEffectsIndex < 0){
        for(int i = 0; i < [STDefaultSetting sharedInstace].wholeMakeUpModels.count; i++){
            [STDefaultSetting sharedInstace].wholeMakeUpModels[i].selected = NO;
        }
    }else{
        [STDefaultSetting sharedInstace].wholeMakeUpModels[wholeEffectsIndex].selected = YES;
    }
    return wholeEffectsIndex >= 0;
}


- (void)selectBeautyFromDiskWithType:(STEffectsType)type {
    if ([STDefaultSetting sharedInstace].beautyModelFromCache) {
        STNewBeautyCollectionViewModel *beautyModelFromCache = [STDefaultSetting sharedInstace].beautyModelFromCache;
        NSArray *array = nil;
        switch (type) {
            case STEffectsTypeBeautyWholeMakeup:
                array = [STDefaultSetting sharedInstace].wholeMakeUpModels;
                break;
            case STEffectsTypeBeautyBase:
                array = [STDefaultSetting sharedInstace].baseBeautyModels;
                break;
            case STEffectsTypeBeautyShape:
                array = [STDefaultSetting sharedInstace].beautyShapeModels;
                break;
            case STEffectsTypeBeautyMicroSurgery:
                array = [STDefaultSetting sharedInstace].microSurgeryModels;
                break;
            case STEffectsTypeBeautyAdjust:
                array = [STDefaultSetting sharedInstace].adjustModels;
                break;
            default:
                break;
        }
        
        //从新设置数据源
        //这里要更新一下setting default settings
        [[STDefaultSetting sharedInstace] setDefaultBeautyValues];
        
        if (array) {
            self.beautyCollectionView.models = array;
            int index = (int)[self getBeautyIndex:beautyModelFromCache.title];
            self.beautyCollectionView.models[index].selected = YES;
            self.currentModel = self.beautyCollectionView.models[index];
            [self.beautyCollectionView reloadData];
        }
    }
}

- (NSUInteger)getBeautyIndex:(NSString *)name{
    __block NSUInteger index = 0;
    [self.beautyCollectionView.models enumerateObjectsUsingBlock:^(STNewBeautyCollectionViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.title isEqualToString:name]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

- (void)selectFilterFromDiskWithValue:(BOOL)value{ // 从缓存中读取滤镜
    //restore UIs
    if ([STDefaultSetting sharedInstace].filterModelFromCache) {
        STCollectionViewDisplayModel *filterModel = [STDefaultSetting sharedInstace].filterModelFromCache;
        NSArray *array = nil;
        switch (filterModel.modelType) {
            case STEffectsTypeFilterPortrait:
                array = [STDefaultSetting sharedInstace].filterDataSources[@(STEffectsTypeFilterPortrait)];
                break;
            case STEffectsTypeFilterScenery:
                array = [STDefaultSetting sharedInstace].filterDataSources[@(STEffectsTypeFilterScenery)];
                break;
            case STEffectsTypeFilterStillLife:
                array = [STDefaultSetting sharedInstace].filterDataSources[@(STEffectsTypeFilterStillLife)];
                break;
            case STEffectsTypeFilterDeliciousFood:
                array = [STDefaultSetting sharedInstace].filterDataSources[@(STEffectsTypeFilterDeliciousFood)];
                break;
            default:
                break;
        }
        if (array) {
            self.filterView.filterCollectionView.arrModels = array;
            //set filter here
            [self.filterView reload];
            //update filter value
            if (value) {
                [self handleFilterChanged:array[[self getFilterIndex:filterModel.strName]]];
                self.sliderView.filterSlide.value = (int)[STDefaultSetting sharedInstace].oWholeFilterValue;
                self.sliderView.filterValue.text = [NSString stringWithFormat:@"%.f", [STDefaultSetting sharedInstace].oWholeFilterValue];
            }
        }
    }
}

- (NSUInteger)getFilterIndex:(NSString *)name{
    __block NSUInteger index = 0;
    [self.filterView.filterCollectionView.arrModels enumerateObjectsUsingBlock:^(STCollectionViewDisplayModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.strName isEqualToString:name]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

- (void)selectMakeupFromDiskWithValue:(BOOL)value{
    if (value) {
        NSMutableSet *set = [NSMutableSet set];
        NSArray *array = [NSArray arrayWithArray:[STDefaultSetting sharedInstace].makeUpModelsFormCache];
        for(STMakeupDataModel *model in array){
            [set addObject:model];
        }
        //set makeup here
        self.bmpColView.m_bmpDetailColV.wholeBeautyType = [STDefaultSetting sharedInstace].beautyModelFromCache.beautyType;
        [self.bmpColView.m_bmpDetailColV.defaultMakeups setObject:array forKey:@(self.bmpColView.m_bmpDetailColV.wholeBeautyType)];
        [self.bmpColView.m_bmpDetailColV restorePreSelectedMakeUps:set];
        //update make value
        self.sliderView.makeupSlide.value = (int)[STDefaultSetting sharedInstace].oWholeMakeUpValue;
        self.sliderView.makeupValue.text = [NSString stringWithFormat:@"%.f", [STDefaultSetting sharedInstace].oWholeMakeUpValue];
        [self.bmpColView.m_bmpDetailColV updateMakeupValue:set makeupValue:[STDefaultSetting sharedInstace].oWholeMakeUpValue/100.0];
        [[STDefaultSetting sharedInstace].makeUpModelsFormCache removeAllObjects];
    }
}

#pragma mark - damen： getter & setter
-(STCoreStateManagement *)coreStateMangement {
    if (!_coreStateMangement) {
        _coreStateMangement = [[STCoreStateManagement alloc] init];
        _coreStateMangement.valueChangeDelegate = self;
    }
    return _coreStateMangement;
}

#pragma mark - STCoreStateManagementValueChangeDelegate
-(void)coreStateManagement:(STCoreStateManagement *)management filterModelValueChanged:(STCollectionViewDisplayModel *)filterModel {
    if (filterModel.modelType != STEffectsTypeNone) {
        dispatch_async(dispatch_get_main_queue(), ^{
            STViewButton * viewButton = [self.filterCategoryView viewWithTag:filterModel.modelType];
            if (viewButton) {
                viewButton.highlighted = YES;
            }
        });
    }
}

- (void)setBeautyParamsWithType:(STNewBeautyCollectionViewModel *)model{
    [[STDefaultSetting sharedInstace] setBeuatyParamsWithHandle:_hEffectHandle model:model];
}

- (void)setBeautyParams{
    [[STDefaultSetting sharedInstace] setBeautyParamsWithHandle:_hEffectHandle];
}

-(void)dealloc {
    if (_overlap_callback_block) _overlap_callback_block = nil;
}

- (void)getOverLap{
    if (self.overlap_callback_block) {
        int beauty_num = 0;
        st_mobile_effect_get_overlapped_beauty_count(_hEffectHandle, &beauty_num);
        st_effect_beauty_info_t p_beauty_infos[beauty_num];
        st_mobile_effect_get_overlapped_beauty(_hEffectHandle, p_beauty_infos, beauty_num);
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        for(int i = 0; i < beauty_num; i++){
//            [dic setObject:@(p_beauty_infos[i].strength) forKey:@(p_beauty_infos[i].type)];
//        }
//        NSLog(@"@@@@@ dic %@", dic);
        BOOL has4xx = NO, has5xx = NO;
        if (sizeof(p_beauty_infos) / sizeof(st_effect_beauty_info_t) > 0) {
            for (int i = 0; i <  sizeof(p_beauty_infos) / sizeof(st_effect_beauty_info_t); i ++) {
                [[STDefaultSetting sharedInstace] setBeautyParamsWithBeautyInfo:p_beauty_infos[i]];
                if (p_beauty_infos[i].type >= 400 && p_beauty_infos[i].type < 500) {
                    has4xx = YES;
                } else if (p_beauty_infos[i].type >= 500) {
                    has5xx = YES;
                }
            }
            [self setBeautyParams];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self restoreStickerStateBeayManu:NO];
            });
        }
        if (self.overlap_callback_block) self.overlap_callback_block(has4xx, has5xx);
    }
}

@end
