//
//  STBMPDetailColV.m
//  SenseMeEffects
//
//  Created by sensetimesunjian on 2019/5/10.
//  Copyright © 2019 SenseTime. All rights reserved.
//

#import "STBMPDetailColV.h"
#import "STBMPDetailColVCell.h"
#import "SenseArSourceService.h"
#import "STCustomMemoryCache.h"
#import "STDefaultSetting.h"

#import "DefaultBeautyParameters.h"
#import <YYModel/YYModel.h>

@interface STBMPDetailColV ()

@property (nonatomic, strong) STMakeupDataModel *bmpModel;
@property (nonatomic, assign) STBMPTYPE m_bmpType;

//cache
@property (nonatomic, strong) NSLock *cacheLock;
@property (nonatomic, strong) NSMutableDictionary *memoryCache;
@property (nonatomic, copy)   NSString *diskCachPath;
@property (nonatomic, strong) dispatch_queue_t thumbQueue;

@end

@implementation STBMPDetailColV

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetUis) name:@"resetUIs" object:nil];
        
        [self setupDefaults];
        
        [self setupUIs];
        
        [self setupCache];
        
        __weak typeof(self) weakSelf = self;
        self.STBmpDetailBlock = ^(float value) {
            [weakSelf updateWhileMakeValue:value];
        };
        
        return self;
    }
    
    return nil;
}

- (void)setupDefaults{
    _defaultMakeups = [NSMutableDictionary new];
}


- (void)updateMakeupValue:(NSSet *)array makeupValue:(float)value{
    for(STMakeupDataModel *model in array){
        float strength = value;
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(updateWholemakeup:currentValue:)]) {
            [self.delegate updateWholemakeup:model
                                currentValue:strength];
        }
    }
}


- (void)updateWhileMakeValue:(float)value{
    if (!_defaultMakeups) return;
    NSArray <STMakeupDataModel *> *array = _defaultMakeups[@(_wholeBeautyType)];
    if (!array) return;
    for(STMakeupDataModel *model in array){
        float strength = value;
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(updateWholemakeup:currentValue:)]) {
            [self.delegate updateWholemakeup:model
                                currentValue:strength];
        }
    }
}

- (void)restorePreSelectedMakeUps:(NSSet *)array{
    [self refreshMakeupSources];
    NSMutableSet * sets = [NSMutableSet setWithSet:array];
    for(STMakeupDataModel *model in sets){
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(didSelectedModel:toTop:)]) {
            [self.delegate didSelectedModel:model toTop:YES];
        }
    }
}

- (void)setupCache{
    self.cacheLock = [[NSLock alloc] init];
    self.memoryCache = [NSMutableDictionary dictionary];
    NSString *file = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    file = [file stringByAppendingPathComponent:@"STMakeUp"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:file]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:file withIntermediateDirectories:YES attributes:nil error:nil];
    }
    self.diskCachPath = file;
    self.thumbQueue = dispatch_queue_create("com.sensetime.STMakeupQueue", DISPATCH_QUEUE_CONCURRENT);
}



- (void)resetIndex{
//    _m_wholeMakeIndex = _m_lipsIndex = _m_cheekIndex = _m_browIndex = _m_eyeShadowIndex = _m_eyeLinerIndex = _m_eyeLashIndex = _m_noseIndex = _m_eyeballIndex = _m_maskhariIndex= 0;
}

- (void)resetUis{
    [self resetIndex];
    [_m_bmpDtColV reloadData];
    [self resetBmp];
}

- (void)resetBmp{
    STMakeupDataModel *resetModel = [[STMakeupDataModel alloc] init];
    resetModel.m_bmpStrength = 0.8;
    for (int i = 0; i < STBMPTYPE_COUNT; ++i) {
        resetModel.m_bmpType = i;
        if (self.delegate) {
            [self.delegate didSelectedModel:resetModel toTop:NO];
        }
    }
}
//下载模型
- (void)downloadMaterialWithModel:(STMakeupDataModel *)model
                            block:(void(^)(STMakeupDataModel *))block{
//    BOOL isMaterialExist = [[SenseArMaterialService sharedInstance] isMaterialDownloaded:model.m_material];
    BOOL isMaterialExist = [[EFMaterialDownloadStatusManager sharedInstance] efDownloadStatus:model.NewMaterial];
    BOOL isDirectory = YES;
    BOOL isFileAvalible = [[NSFileManager defaultManager] fileExistsAtPath:model.m_zipPath
                                                               isDirectory:&isDirectory];
    if (isMaterialExist && (isDirectory || !isFileAvalible)) {
        model.m_zipPath = nil;
        isMaterialExist = NO;
    }
    if (model && model.NewMaterial && !isMaterialExist) {
        [[EFMaterialDownloadStatusManager sharedInstance] efStartDownload:model.NewMaterial onProgress:^(id<EFDataSourcing> material, float fProgress, int64_t iSize) {
                    
                } onSuccess:^(id<EFDataSourcing> material) {
                    model.m_zipPath = material.efMaterialPath;
                    if (block) {
                        block(model);
                    }
                } onFailure:^(id<EFDataSourcing> material, int iErrorCode, NSString *strMessage) {
                    if (block) {
                        block(nil);
                    }
                }];

    }else{
        block(model);
    }
}

- (void)refreshMakeupSources{
    if (!self.m_wholeMakeArr.count)self.m_wholeMakeArr = [STDefaultSetting sharedInstace].m_wholeMakeArr;
    if (!self.m_lipsArr.count)self.m_lipsArr= [STDefaultSetting sharedInstace].m_lipsArr;
    if (!self.m_cheekArr.count)self.m_cheekArr= [STDefaultSetting sharedInstace].m_cheekArr;
    if (!self.m_browsArr.count)self.m_browsArr= [STDefaultSetting sharedInstace].m_browsArr;
    if (!self.m_eyeshadowArr.count)self.m_eyeshadowArr= [STDefaultSetting sharedInstace].m_eyeshadowArr;
    if (!self.m_eyelinerArr.count)self.m_eyelinerArr= [STDefaultSetting sharedInstace].m_eyelinerArr ? [STDefaultSetting sharedInstace].m_eyelinerArr : [NSMutableArray array];
    if (!self.m_eyelashArr.count)self.m_eyelashArr= [STDefaultSetting sharedInstace].m_eyelashArr;
    if (!self.m_noseArr.count)self.m_noseArr= [STDefaultSetting sharedInstace].m_noseArr;
    if (!self.m_eyeballArr.count) self.m_eyeballArr= [STDefaultSetting sharedInstace].m_eyeballArr ? [STDefaultSetting sharedInstace].m_eyeballArr : [NSMutableArray array];
    if (!self.m_maskhairArr.count)self.m_maskhairArr= [STDefaultSetting sharedInstace].m_maskhairArr ? [STDefaultSetting sharedInstace].m_maskhairArr : [NSMutableArray array];
}

- (void)clearAllMakeups{
    [self refreshMakeupSources];
    
    if(!_m_wholeMakeArr ||
       !_m_lipsArr ||
       !_m_cheekArr ||
       !_m_browsArr ||
       !_m_eyeshadowArr ||
       !_m_eyelinerArr ||
       !_m_eyelashArr ||
       !_m_noseArr ||
       !_m_eyeballArr ||
       !_m_maskhairArr) return;
    NSArray *makeups = @[_m_wholeMakeArr,
                         _m_lipsArr,
                         _m_cheekArr,
                         _m_browsArr,
                         _m_eyeshadowArr,
                         _m_eyelinerArr,
                         _m_eyelashArr,
                         _m_noseArr,
                         _m_eyeballArr,
                         _m_maskhairArr];
    for(NSArray<STMakeupDataModel *> *models in makeups){
        for(STMakeupDataModel *model in models){
            model.m_selected = NO;
        }
    }
}

- (void)setDefaultModelArray:(NSArray<STMakeupDataModel *> *)array value:(float)value{
    for (int i = 0; i < array.count; i++) {
        array[i].m_bmpStrength = value;
    }
}

- (void)wholeMakeUp:(STBeautyType)beautyType {
    _wholeBeautyType = beautyType;
    BOOL hasItem = NO;
    NSMutableArray *array = _defaultMakeups[@(beautyType)];
    if (array.count) {
        hasItem = YES;
    }else{
        NSMutableArray *array = [NSMutableArray array];
        _defaultMakeups[@(beautyType)] = array;
    }
    
    [self resetIndex];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cleanMakeup)]) {
        [self.delegate cleanMakeup];
    }
    
    //clear all
    [self clearAllMakeups];
    STMakeupDataModel *model = nil;
    if (beautyType == STBeautyTypeMakeupZBYuanQi) {
        for (int i = 0; i < self.m_lipsArr.count; i++) {
            model = self.m_lipsArr[i];
            if ([model.m_name  isEqual: @"12自然"]) {
                model.m_selected = YES;
                model.m_bmpStrength = 0.54 * 85 / 100;
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
                
            }
        }
    
        for (int i = 0; i < self.m_browsArr.count; i++) {
            model = self.m_browsArr[i];
            if ([model.m_name  isEqual: @"browb"]) {
                model.m_selected = YES;
                model.m_bmpStrength = 0.20 * 85 / 100;
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
                
            }
        }
    
        for (int i = 0; i < self.m_eyeshadowArr.count; i++) {
            model = self.m_eyeshadowArr[i];
            if ([model.m_name  isEqual: @"eyeshadowa"]) {
                model.m_selected = YES;
                model.m_bmpStrength = 0.80 * 85 / 100;
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
                
            }
        }
        
        for (int i = 0; i < self.m_eyelashArr.count; i++) {
            model = self.m_eyelashArr[i];
            if ([model.m_name  isEqual: @"eyelashk"]) {
                model.m_selected = YES;
                model.m_bmpStrength = 0.40 * 85 / 100;
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
                
            }
        }
        
    }else if (beautyType == STBeautyTypeMakeupZBZiRan) {

        for (int i = 0; i < self.m_lipsArr.count; i++) {
            model = self.m_lipsArr[i];
            if ([model.m_name  isEqual: @"11自然"]) {
                model.m_selected = YES;
                model.m_bmpStrength = 0.25 * 85 / 100;
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
                
            }
        }
        
        for (int i = 0; i < self.m_cheekArr.count; i++) {
            model = self.m_cheekArr[i];
            if ([model.m_name  isEqual: @"blusha"]) {
                model.m_selected = YES;
                model.m_bmpStrength = 0.23 * 85 / 100;
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
                
            }
        }
        
        for (int i = 0; i < self.m_browsArr.count; i++) {
            model = self.m_browsArr[i];
            if ([model.m_name  isEqual: @"browb"]) {
                model.m_selected = YES;
                model.m_bmpStrength = 0.15 * 85 / 100;
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
                
            }
        }
        
    }else if (beautyType == STBeautyTypeMakeupZPYuanQi) {

        for (int i = 0; i < self.m_lipsArr.count; i++) {
            model = self.m_lipsArr[i];
            if ([model.m_name  isEqual: @"11自然"]) {
                model.m_selected = YES;
                model.m_bmpStrength = 0.25 * 85 / 100;
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
                
            }
        }
        
        for (int i = 0; i < self.m_cheekArr.count; i++) {
            model = self.m_cheekArr[i];
            if ([model.m_name  isEqual: @"blusha"]) {
                model.m_selected = YES;
                model.m_bmpStrength = 0.40 * 85 / 100;
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
                
            }
        }
        
        for (int i = 0; i < self.m_browsArr.count; i++) {
            model = self.m_browsArr[i];
            if ([model.m_name  isEqual: @"browb"]) {
                model.m_selected = YES;
                model.m_bmpStrength = 0.15 * 85 / 100;
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
                
            }
        }
    }else if (beautyType == STBeautyTypeMakeupZBYuanHua) {
        //update Collection UI
        [self resetBmp];
    }else if (beautyType == STBeautyTypeMakeupNvshen){
        for (int i = 0; i < self.m_wholeMakeArr.count; i++) {
            model = self.m_wholeMakeArr[i];
            if ([model.m_name  isEqual: @"nvshen"]) {
                model.m_selected = YES;
                model.m_bmpStrength = stm_default_nvshen_makeup_value * 85 / 100;
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
            }
        }
    }
    else if (beautyType == STBeautyTypeMakeupWhitetea){
        for (int i = 0; i < self.m_wholeMakeArr.count; i++) {
            model = self.m_wholeMakeArr[i];
            if ([model.m_name  isEqual: @"whitetea"]) {
                model.m_selected = YES;
                model.m_bmpStrength = stm_default_whiteTea_makeup_value * 85 / 100;
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
                [self setDefaultModelArray:self.m_wholeMakeArr value:model.m_bmpStrength];
                break;
            }
        }
    }
    else if (beautyType == STBeautyTypeMakeupRedwine){
        for (int i = 0; i < self.m_wholeMakeArr.count; i++) {
            model = self.m_wholeMakeArr[i];
            if ([model.m_name  isEqual: @"redwine"]) {
                model.m_selected = YES;
                model.m_bmpStrength = stm_default_redwine_makeup_value * 85 / 100;
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
                [self setDefaultModelArray:self.m_wholeMakeArr value:model.m_bmpStrength];
                break;
            }
        }
    }
    
    else if (beautyType == STBeautyTypeMakeupSweet){
        for (int i = 0; i < self.m_wholeMakeArr.count; i++) {
            model = self.m_wholeMakeArr[i];
            if ([model.m_name isEqual: @"sweet"]) {
                model.m_selected = YES;
                model.m_bmpStrength = stm_default_sweet_makeup_value * 85 / 100;
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
                [self setDefaultModelArray:self.m_wholeMakeArr value:model.m_bmpStrength];
                break;
            }
        }
    }
    else if (beautyType == STBeautyTypeMakeupWestern){
        for (int i = 0; i < self.m_wholeMakeArr.count; i++) {
            model = self.m_wholeMakeArr[i];
            if ([model.m_name  isEqual: @"western"]) {
                model.m_selected = YES;
                model.m_bmpStrength = stm_default_western_makeup_value * 85 / 100;
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
                [self setDefaultModelArray:self.m_wholeMakeArr value:model.m_bmpStrength];
                break;
            }
        }
    }
    else if (beautyType == STBeautyTypeMakeupZhigan){
        for (int i = 0; i < self.m_wholeMakeArr.count; i++) {
            model = self.m_wholeMakeArr[i];
            if ([model.m_name  isEqual: @"zhigan"]) {
                model.m_selected = YES;
                model.m_bmpStrength = stm_default_zhigan_makeup_value * 85 / 100;
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
                [self setDefaultModelArray:self.m_wholeMakeArr value:model.m_bmpStrength];
                break;
            }
        }
    }
    else if (beautyType == STBeautyTypeMakeupDeep){
        for (int i = 0; i < self.m_wholeMakeArr.count; i++) {
            STMakeupDataModel *model = self.m_wholeMakeArr[i];
            if ([model.m_name  isEqual: @"deep"]) {
                model.m_selected = YES;
                model.m_bmpStrength = stm_default_deep_makeup_value * 85 / 100;
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
                
            }
        }
    }
    
    else if (beautyType == STBeautyTypeMakeupTianran){
        for (int i = 0; i < self.m_wholeMakeArr.count; i++) {
            STMakeupDataModel *model = self.m_wholeMakeArr[i];
            if ([model.m_name  isEqual: @"tianran"]) {
                model.m_selected = YES;
//                model.m_bmpStrength = 0.60 * 85 / 100;
                model.m_bmpStrength = stm_default_tianran_makeup_value * 85 / 100;
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
                
            }
        }
    }
    else if (beautyType == STBeautyTypeMakeupSweetgirl){
        for (int i = 0; i < self.m_wholeMakeArr.count; i++) {
            STMakeupDataModel *model = self.m_wholeMakeArr[i];
            if ([model.m_name  isEqual: @"sweetgirl"]) {
                model.m_selected = YES;
                model.m_bmpStrength = stm_default_sweetgirl_makeup_value * 85 / 100;
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
                
            }
        }
    }
    else if (beautyType == STBeautyTypeMakeupOxygen){
        for (int i = 0; i < self.m_wholeMakeArr.count; i++) {
            STMakeupDataModel *model = self.m_wholeMakeArr[i];
            if ([model.m_name  isEqual: @"oxygen"]) {
                model.m_selected = YES;
                model.m_bmpStrength = stm_default_oxygen_makeup_value * 85 / 100;
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
                
            }
        }
    }
    else if(beautyType == STBeautyTypeMakeupZPZiRan){
        for (int i = 0; i < self.m_lipsArr.count; i++) {
            STMakeupDataModel *model = self.m_lipsArr[i];
            if ([model.m_name  isEqual: @"6自然"]) {
                model.m_selected = YES;
                model.m_bmpStrength = 0.40 * 85 / 100;
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
            }
        }
        
        for (int i = 0; i < self.m_noseArr.count; i++) {
            STMakeupDataModel *model = self.m_noseArr[i];
            if ([model.m_name  isEqual: @"faceE"]) {
                model.m_selected = YES;
                model.m_bmpStrength = 0.58 * 85 / 100;
                if (self.delegate) [self.delegate didSelectedModel:model toTop:YES];
                if(!hasItem) [_defaultMakeups[@(beautyType)] addObject:model];
            }
        }
    }
    [_m_bmpDtColV reloadData];
}

- (void)clearMakeUp {
    [self resetUis];
}

- (void)zeroMakeUp {
    _bmpModel = nil;
    [self clearAllMakeups];
    
    if (self.delegate) {
        [self.delegate zeroSelectedModels];
    }
    [_m_bmpDtColV reloadData];
}

- (void)reload{
    [_m_bmpDtColV reloadData];
}

- (void)setupUIs
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(70, 80);
    flowLayout.minimumInteritemSpacing = 1;
    flowLayout.minimumLineSpacing = 5;
    flowLayout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.m_bmpDtColV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, 85) collectionViewLayout:flowLayout];
    self.m_bmpDtColV.delegate = self;
    self.m_bmpDtColV.dataSource = self;
    self.m_bmpDtColV.backgroundColor = [UIColor clearColor];
    self.m_bmpDtColV.showsVerticalScrollIndicator = NO;
    [self.m_bmpDtColV registerClass:[STBMPDetailColVCell class] forCellWithReuseIdentifier:@"STBMPDetailColVCell"];
    [self addSubview:self.m_bmpDtColV];
}

- (void)didSelectedBmpType:(STMakeupDataModel *)model{
    _m_bmpType = model.m_bmpType;
    [_m_bmpDtColV reloadData];
}

#pragma collectionDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    [self refreshMakeupSources];
    switch (_m_bmpType) {
        case STBMPTYPE_WHOLEMAKEUP:
            return _m_wholeMakeArr.count;
            break;
        case STBMPTYPE_EYE_SHADOW:
            return _m_eyeshadowArr.count;
            break;
        case STBMPTYPE_EYE_LINER:
            return _m_eyelinerArr.count;
            break;
        case STBMPTYPE_EYE_LASH:
            return _m_eyelashArr.count;
            break;
        case STBMPTYPE_LIP:
            return _m_lipsArr.count;
            break;
        case STBMPTYPE_EYE_BROW:
            return _m_browsArr.count;
            break;
        case STBMPTYPE_CHEEK:
            return _m_cheekArr.count;
            break;
        case STBMPTYPE_NOSE:
            return _m_noseArr.count;
            break;
        case STBMPTYPE_EYE_BALL:
            return _m_eyeballArr.count;
            break;
        case STBMPTYPE_MASKHAIR:
            return _m_maskhairArr.count;
            break;
        case STBMPTYPE_COUNT:
            break;
    }
    return 0;
}


#pragma dataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    STBMPDetailColVCell *cell = (STBMPDetailColVCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STBMPDetailColVCell" forIndexPath:indexPath];
    STMakeupDataModel *model = nil;
    int index = (int)indexPath.row;
    //判断是否选中
    switch (_m_bmpType) {
        case STBMPTYPE_MASKHAIR:
            model = _m_maskhairArr[index];
            [cell setDidSelected:model.m_selected];
            break;
        case STBMPTYPE_LIP:
            model = _m_lipsArr[index];
            [cell setDidSelected:model.m_selected];
            break;
        case STBMPTYPE_CHEEK:
            model = _m_cheekArr[index];
            [cell setDidSelected:model.m_selected];
            break;
        case STBMPTYPE_NOSE:
            model = _m_noseArr[index];
            [cell setDidSelected:model.m_selected];
            break;
        case STBMPTYPE_EYE_BROW:
            model = _m_browsArr[index];
            [cell setDidSelected:model.m_selected];
            break;
        case STBMPTYPE_EYE_SHADOW:
            model =_m_eyeshadowArr[index];
            [cell setDidSelected:model.m_selected];
            break;
        case STBMPTYPE_EYE_LINER:
            model = _m_eyelinerArr[index];
            [cell setDidSelected:model.m_selected];
            break;
        case STBMPTYPE_EYE_LASH:
            model = _m_eyelashArr[index];
            [cell setDidSelected:model.m_selected];
            break;
        case STBMPTYPE_EYE_BALL:
            model = _m_eyeballArr[index];
            [cell setDidSelected:model.m_selected];
            break;
        case STBMPTYPE_WHOLEMAKEUP:
            model = _m_wholeMakeArr[index];
            [cell setDidSelected:model.m_selected];
            break;
        case STBMPTYPE_COUNT:
            break;
    }
    //设置icon
    [cell setName:model.m_name];
    [cell setState:model.m_state];
    if (!model.m_fromOnLine) {
        [cell setIcon:model.m_iconDefault];
    }else{
        if (model.m_thumbImage) {
            [cell setIcon:model.m_thumbImage];
        }else{
            [self getImageWithModel:model block:^(UIImage *image){
                model.m_thumbImage = image;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setIcon:model.m_thumbImage];
                });
            }];
        }
    }
    return cell;
}
//设置model图片
- (void)getImageWithModel:(STMakeupDataModel *)model block:(void(^)(UIImage *))block{
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.thumbQueue, ^{
        //memory Cahce
        UIImage *memoryimage = [weakSelf.memoryCache objectForKey:model.m_iconDefault];
        if (!memoryimage) {
            //file cache
            
            UIImage *fileImage = [UIImage imageNamed:[weakSelf.diskCachPath stringByAppendingPathComponent:model.m_iconDefault]];
            NSURL *url = [NSURL URLWithString:model.m_iconDefault];
            if (!fileImage && url) {
//                model.m_iconDefault = [model.m_iconDefault stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                
                NSData *imageData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:nil];
                UIImage *webImage = [UIImage imageWithData:imageData];
                if (webImage){
                    [weakSelf.cacheLock lock];
                    //update memoryCahce
                    [weakSelf.memoryCache setObject:webImage forKey:model.m_iconDefault];
                    //update memoryCache
                    [[NSFileManager defaultManager] createFileAtPath:[weakSelf.diskCachPath stringByAppendingPathComponent:model.m_iconDefault] contents:imageData attributes:nil];
                    [weakSelf.cacheLock unlock];
                    block(webImage);
                }


            }else{
                block(fileImage);
            }
        }else{
            block(memoryimage);
        }
    });
}

- (void)clearState:(NSArray<STMakeupDataModel *> *)array{
    for(int i = 0; i < array.count; i++){
        array[i].m_selected = NO;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    STMakeupDataModel *model = nil;
    switch (_m_bmpType) {
        case STBMPTYPE_WHOLEMAKEUP:{
            [self clearAllMakeups];
            model = _m_wholeMakeArr[(int)indexPath.row];
            if ([_bmpModel isEqual:model]) {
                model.m_selected = NO;
                _bmpModel = nil;
            }else{
                model.m_selected = YES;
                _bmpModel = model;
            }
        }
            break;
        case STBMPTYPE_EYE_SHADOW:{
            [self clearState:_m_eyeshadowArr];
            model = _m_eyeshadowArr[(int)indexPath.row];
            if ([_bmpModel isEqual:model]) {
                model.m_selected = NO;
                _bmpModel = nil;
            }else{
                model.m_selected = YES;
                _bmpModel = model;
            }
            break;
        }
           
        case STBMPTYPE_EYE_LINER:{
            [self clearState:_m_eyelinerArr];
            model = _m_eyelinerArr[(int)indexPath.row];
            if ([_bmpModel isEqual:model]) {
                model.m_selected = NO;
                _bmpModel = nil;
            }else{
                model.m_selected = YES;
                _bmpModel = model;
            }
            break;
        }
            
        case STBMPTYPE_EYE_LASH:{
            [self clearState:_m_eyelashArr];
            model = _m_eyelashArr[(int)indexPath.row];
            if ([_bmpModel isEqual:model]) {
                model.m_selected = NO;
                _bmpModel = nil;
            }else{
                model.m_selected = YES;
                _bmpModel = model;
            }
            break;
        }
            
        case STBMPTYPE_LIP:{
            [self clearState:_m_lipsArr];
            model = _m_lipsArr[(int)indexPath.row];
            if ([_bmpModel isEqual:model]) {
                model.m_selected = NO;
                _bmpModel = nil;
            }else{
                model.m_selected = YES;
                _bmpModel = model;
            }
            break;
        }
           
        case STBMPTYPE_EYE_BROW:{
            [self clearState:_m_browsArr];
            model = _m_browsArr[(int)indexPath.row];
            if ([_bmpModel isEqual:model]) {
                model.m_selected = NO;
                _bmpModel = nil;
            }else{
                model.m_selected = YES;
                _bmpModel = model;
            }
            break;
        }
            
        case STBMPTYPE_CHEEK:{
            [self clearState:_m_cheekArr];
            model = _m_cheekArr[(int)indexPath.row];
            if ([_bmpModel isEqual:model]) {
                model.m_selected = NO;
                _bmpModel = nil;
            }else{
                model.m_selected = YES;
                _bmpModel = model;
            }
            break;
        }
          
        case STBMPTYPE_NOSE:{
            [self clearState:_m_noseArr];
            model = _m_noseArr[(int)indexPath.row];
            if ([_bmpModel isEqual:model]) {
                model.m_selected = NO;
                _bmpModel = nil;
            }else{
                model.m_selected = YES;
                _bmpModel = model;
            }
            break;
        }
            
        case STBMPTYPE_EYE_BALL:{
            [self clearState:_m_eyeballArr];
            model = _m_eyeballArr[(int)indexPath.row];
            if ([_bmpModel isEqual:model]) {
                model.m_selected = NO;
                _bmpModel = nil;
            }else{
                model.m_selected = YES;
                _bmpModel = model;
            }
            break;
        }
            
        case STBMPTYPE_MASKHAIR:{
            [self clearState:_m_maskhairArr];
            model = _m_maskhairArr[(int)indexPath.row];
            if ([_bmpModel isEqual:model]) {
                model.m_selected = NO;
                _bmpModel = nil;
            }else{
                model.m_selected = YES;
                _bmpModel = model;
            }
            break;
        }
        case STBMPTYPE_COUNT:
            break;
        default:
            break;
    }
    if (!model.m_fromOnLine) {
        if (self.delegate) {
            [self.delegate didSelectedModel:model toTop:YES];
        }
        [_m_bmpDtColV reloadData];
    }else{
        model.m_state = STStateDownloading;
        [_m_bmpDtColV reloadData];
        __weak typeof(self) weakSelf = self;
        [self downloadMaterialWithModel:model
                                  block:^(STMakeupDataModel *model) {
            dispatch_async(dispatch_get_main_queue(), ^{
                model.m_state = STStateDownloaded;
                if (weakSelf.delegate && model) {
                    [weakSelf.delegate didSelectedModel:model toTop:YES];
                }
                [_m_bmpDtColV reloadData];
            });
        }];
    }
    [self.delegate didSelectedModelByManu];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"resetUIs" object:nil];
}
@end
