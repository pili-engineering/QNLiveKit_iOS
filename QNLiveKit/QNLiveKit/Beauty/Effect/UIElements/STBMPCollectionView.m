//
//  STBeautyMakeUpCollectionView.m
//  SenseMeEffects
//
//  Created by sensetimesunjian on 2019/5/10.
//  Copyright © 2019 SenseTime. All rights reserved.
//

#import "STBMPCollectionView.h"
#import "STBMPCollectionViewCell.h"
#import "UIView+Toast.h"

@interface STBMPCollectionView ()<UICollectionViewDelegate,UICollectionViewDataSource,STBMPDetailColVDelegate>
//ui
@property (nonatomic, strong) UIView *m_backBaseV;
@property (nonatomic, strong) UIImageView *m_backImgV;
@property (nonatomic, strong) UIButton *m_backBtn;
@property (nonatomic, strong) UILabel *m_itemName;
@property (nonatomic, strong) UICollectionView *m_bmpTypeColv;

//data source
@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *>*m_bmpTypeArr;
@property (nonatomic, strong) STMakeupDataModel *m_curModel;


@end

@implementation STBMPCollectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetUis) name:@"resetUIs" object:nil];
        
        [self setupDefaults];
        
        [self setupUIs];
        
        return self;
    }
    
    return nil;
}

- (void)setupDefaults{
    NSArray *types = @[NSLocalizedString(@"整妆", nil),
                       NSLocalizedString(@"染发", nil),
                       NSLocalizedString(@"口红", nil),
                       NSLocalizedString(@"腮红", nil),
                       NSLocalizedString(@"修容", nil),
                       NSLocalizedString(@"眉毛", nil),
                       NSLocalizedString(@"眼影", nil),
                       NSLocalizedString(@"眼线", nil),
                       NSLocalizedString(@"眼睫毛", nil),
                       NSLocalizedString(@"美瞳", nil)];
    NSArray *bmpTypes = @[@(STBMPTYPE_WHOLEMAKEUP),@(STBMPTYPE_MASKHAIR),@(STBMPTYPE_LIP),@(STBMPTYPE_CHEEK),@(STBMPTYPE_NOSE),@(STBMPTYPE_EYE_BROW),@(STBMPTYPE_EYE_SHADOW),@(STBMPTYPE_EYE_LINER),@(STBMPTYPE_EYE_LASH), @(STBMPTYPE_EYE_BALL)];
    NSArray *iconDefaults = @[@"wholemakeup", @"maskHair",@"lip", @"blush",@"face",@"brow",@"eyeshadow-white",@"eyeline-white", @"eyelash-white", @"eyeball"];
    NSArray *iconHightLights = @[@"wholemakeupselect", @"maskHair_purple",@"lip_selected", @"blush_selected",@"face_selected",@"brow_selected",@"eyeshadow-purple",@"eyeline-purple",@"eyelash-purple",@"eyeball_select"];
    self.m_bmpTypeArr = [NSMutableArray array];
    //make sure accurate data source
    for(int i = 0; i < types.count; ++i){
        STMakeupDataModel *model = [[STMakeupDataModel alloc] init];
        model.m_name = types[i];
        model.m_iconDefault = iconDefaults[i];
        model.m_iconHighlight = iconHightLights[i];
        NSNumber *num = bmpTypes[i];
        model.m_bmpType = num.integerValue;
        [_m_bmpTypeArr addObject:model];
    };
}

- (void)wholeMakeUp:(STBeautyType)beautyType {
    //update makeup UI
    if (beautyType == STBeautyTypeMakeupZPYuanQi) {
        for (int i = 0; i < self.m_bmpTypeArr.count; i++) {
            STMakeupDataModel *model = self.m_bmpTypeArr[i];
            if (model.m_bmpType == STBMPTYPE_EYE_BROW   ||
                model.m_bmpType == STBMPTYPE_LIP        ||
                model.m_bmpType == STBMPTYPE_CHEEK) {
                model.m_selected = true;
            }else {
                model.m_selected = false;
            }
        }
    }else if (beautyType == STBeautyTypeMakeupZBYuanQi) {
        for (int i = 0; i < self.m_bmpTypeArr.count; i++) {
            STMakeupDataModel *model = self.m_bmpTypeArr[i];
            if (model.m_bmpType == STBMPTYPE_EYE_BROW   ||
                model.m_bmpType == STBMPTYPE_LIP        ||
                model.m_bmpType == STBMPTYPE_EYE_LASH   ||
                model.m_bmpType == STBMPTYPE_EYE_SHADOW) {
                model.m_selected = true;
            }else {
                model.m_selected = false;
            }
        }
    }else if(beautyType == STBeautyTypeMakeupZBYuanHua){
        for (int i = 0; i < self.m_bmpTypeArr.count; i++) {
            STMakeupDataModel *model = self.m_bmpTypeArr[i];
            model.m_selected = false;
        }
    }else if(beautyType == STBeautyTypeMakeupZPZiRan){
        for (int i = 0; i < self.m_bmpTypeArr.count; i++) {
            STMakeupDataModel *model = self.m_bmpTypeArr[i];
            if (model.m_bmpType == STBMPTYPE_NOSE   ||
                model.m_bmpType == STBMPTYPE_LIP) {
                model.m_selected = true;
            }else {
                model.m_selected = false;
            }
        }
    }else if (beautyType == STBeautyTypeMakeupNvshen){
        for (int i = 0; i < self.m_bmpTypeArr.count; i++) {
            STMakeupDataModel *model = self.m_bmpTypeArr[i];
            if (model.m_bmpType == STBMPTYPE_WHOLEMAKEUP) {
                model.m_selected = true;
            }else {
                model.m_selected = false;
            }
        }
    }else if (beautyType == STBeautyTypeMakeupWhitetea){
        for (int i = 0; i < self.m_bmpTypeArr.count; i++) {
            STMakeupDataModel *model = self.m_bmpTypeArr[i];
            if (model.m_bmpType == STBMPTYPE_WHOLEMAKEUP) {
                model.m_selected = true;
            }else {
                model.m_selected = false;
            }
        }

    }else if (beautyType == STBeautyTypeMakeupRedwine){
        for (int i = 0; i < self.m_bmpTypeArr.count; i++) {
            STMakeupDataModel *model = self.m_bmpTypeArr[i];
            if (model.m_bmpType == STBMPTYPE_WHOLEMAKEUP) {
                model.m_selected = true;
            }else {
                model.m_selected = false;
            }
        }

    }else if (beautyType == STBeautyTypeMakeupSweet){
        for (int i = 0; i < self.m_bmpTypeArr.count; i++) {
            STMakeupDataModel *model = self.m_bmpTypeArr[i];
            if (model.m_bmpType == STBMPTYPE_WHOLEMAKEUP) {
                model.m_selected = true;
            }else {
                model.m_selected = false;
            }
        }

    }else if (beautyType == STBeautyTypeMakeupWestern){
        for (int i = 0; i < self.m_bmpTypeArr.count; i++) {
            STMakeupDataModel *model = self.m_bmpTypeArr[i];
            if (model.m_bmpType == STBMPTYPE_WHOLEMAKEUP) {
                model.m_selected = true;
            }else {
                model.m_selected = false;
            }
        }

    }else if (beautyType == STBeautyTypeMakeupZhigan){
        for (int i = 0; i < self.m_bmpTypeArr.count; i++) {
            STMakeupDataModel *model = self.m_bmpTypeArr[i];
            if (model.m_bmpType == STBMPTYPE_WHOLEMAKEUP) {
                model.m_selected = true;
            }else {
                model.m_selected = false;
            }
        }

    }else if (beautyType == STBeautyTypeMakeupDeep){
        for (int i = 0; i < self.m_bmpTypeArr.count; i++) {
            STMakeupDataModel *model = self.m_bmpTypeArr[i];
            if (model.m_bmpType == STBMPTYPE_WHOLEMAKEUP) {
                model.m_selected = true;
            }else {
                model.m_selected = false;
            }
        }
    }else if (beautyType == STBeautyTypeMakeupTianran){
        for (int i = 0; i < self.m_bmpTypeArr.count; i++) {
            STMakeupDataModel *model = self.m_bmpTypeArr[i];
            if (model.m_bmpType == STBMPTYPE_WHOLEMAKEUP) {
                model.m_selected = true;
            }else {
                model.m_selected = false;
            }
        }
    }else if (beautyType == STBeautyTypeMakeupSweetgirl){
        for (int i = 0; i < self.m_bmpTypeArr.count; i++) {
            STMakeupDataModel *model = self.m_bmpTypeArr[i];
            if (model.m_bmpType == STBMPTYPE_WHOLEMAKEUP) {
                model.m_selected = true;
            }else {
                model.m_selected = false;
            }
        }
    }else if (beautyType == STBeautyTypeMakeupOxygen){
        for (int i = 0; i < self.m_bmpTypeArr.count; i++) {
            STMakeupDataModel *model = self.m_bmpTypeArr[i];
            if (model.m_bmpType == STBMPTYPE_WHOLEMAKEUP) {
                model.m_selected = true;
            }else {
                model.m_selected = false;
            }
        }
    }else {
        for (int i = 0; i < self.m_bmpTypeArr.count; i++) {
            STMakeupDataModel *model = self.m_bmpTypeArr[i];
            if (model.m_bmpType == STBMPTYPE_EYE_BROW   ||
                model.m_bmpType == STBMPTYPE_LIP ){
                model.m_selected = true;
            }else {
                model.m_selected = false;
            }
        }
    }
    [self.m_bmpDetailColV wholeMakeUp:beautyType];
}

- (void)setupUIs{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(80, 90);
    flowLayout.minimumInteritemSpacing = 1;
    flowLayout.minimumLineSpacing = 5;
    flowLayout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.m_bmpTypeColv = [[UICollectionView alloc] initWithFrame:CGRectMake(5, 20, self.frame.size.width, 95) collectionViewLayout:flowLayout];
    self.m_bmpTypeColv.delegate = self;
    self.m_bmpTypeColv.dataSource = self;
    self.m_bmpTypeColv.backgroundColor = [UIColor clearColor];
    self.m_bmpTypeColv.showsVerticalScrollIndicator = NO;
    [self.m_bmpTypeColv registerClass:[STBMPCollectionViewCell class] forCellWithReuseIdentifier:@"STBMPCollectionViewCell"];
    [self addSubview:self.m_bmpTypeColv];
    
    //back btn
    UIView *backBaseV = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 70, 90)];
    [self addSubview:backBaseV];
    backBaseV.backgroundColor = [UIColor clearColor];
    _m_backBaseV = backBaseV;
    backBaseV.hidden = YES;
    
    UIImageView *backImgV = [[UIImageView alloc] initWithFrame:CGRectMake(5, 30, 10, 10)];
    [backBaseV addSubview:backImgV];
    [backImgV setImage:[UIImage imageNamed:@"filter_back_btn"]];
    _m_backImgV = backImgV;
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 5, 60, 60)];
    [backBaseV addSubview:backBtn];
    [backBtn addTarget:self action:@selector(onBackClick) forControlEvents:UIControlEventTouchUpInside];
    _m_backBtn = backBtn;
    
    UILabel *itemName = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(backBtn.frame), 50, 20)];
    itemName.textAlignment = NSTextAlignmentCenter;
    itemName.textColor = [UIColor whiteColor];
    itemName.font = [UIFont systemFontOfSize:14];
    itemName.backgroundColor = [UIColor clearColor];
    [backBaseV addSubview:itemName];
    itemName.center = CGPointMake(_m_backBtn.center.x, itemName.center.y);
    _m_itemName = itemName;
    
    _m_bmpDetailColV = [[STBMPDetailColV alloc] initWithFrame:CGRectMake(CGRectGetMaxX(backBtn.frame), 20, self.frame.size.width - CGRectGetMaxX(backBaseV.frame), 90)];
    [self addSubview:_m_bmpDetailColV];
    _m_bmpDetailColV.hidden = YES;
    _m_bmpDetailColV.delegate = self;
    __weak typeof(self) weakSelf = self;
    self.BMPCollectionViewBlock = ^(float value) {
        [weakSelf update:value];
    };
    
    backBaseV.center = CGPointMake(_m_backBaseV.center.x, _m_bmpDetailColV.center.y);
}

- (void)update:(float)value{
    if (self.m_bmpDetailColV.STBmpDetailBlock) {
        self.m_bmpDetailColV.STBmpDetailBlock(value);
    }
}

- (void)backToMenu
{
    [self onBackClick];
}

- (void)onBackClick
{
    [self backToPreView:YES];
}

- (void)backToPreView:(BOOL)back
{
    if (back) {

        _m_backBaseV.hidden = YES;
        _m_bmpDetailColV.hidden = YES;
        _m_bmpTypeColv.hidden = NO;
    }else{
        
        _m_backBaseV.hidden = NO;
        _m_bmpDetailColV.hidden = NO;
        _m_bmpTypeColv.hidden = YES;
    }
    
    if (self.delegate) {
        [self.delegate backToMainView];
    }
}

- (void)updateUIsWithModel:(STMakeupDataModel *)model{
    if (!model) {
        return;
    }
    _m_itemName.text = model.m_name;
    if (model.m_selected) {
        [_m_backBtn setBackgroundImage:[UIImage imageNamed:model.m_iconHighlight] forState:UIControlStateNormal];
    }else{
        [_m_backBtn setBackgroundImage:[UIImage imageNamed:model.m_iconDefault] forState:UIControlStateNormal];
    }
}

-(void)zeroMakeUp {
    [_m_bmpDetailColV zeroMakeUp];
    
}

- (void)clearMakeUp{
    [_m_bmpDetailColV clearMakeUp];
}

#pragma collectionDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _m_bmpTypeArr.count;
}

#pragma dataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    STBMPCollectionViewCell *cell = (STBMPCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STBMPCollectionViewCell" forIndexPath:indexPath];
    STMakeupDataModel *model = _m_bmpTypeArr[(int)indexPath.row];
    [cell setName:model.m_name];
    if (model.m_selected) {
        [cell setIcon:model.m_iconHighlight];
    }else{
        [cell setIcon:model.m_iconDefault];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    STMakeupDataModel *model = _m_bmpTypeArr[(int)indexPath.row];
    if (model.m_bmpType == STBMPTYPE_WHOLEMAKEUP) {
        for (int i = 0; i < _m_bmpTypeArr.count; i++) {
            STMakeupDataModel *tempModel = _m_bmpTypeArr[i];
            if (tempModel.m_bmpType != STBMPTYPE_WHOLEMAKEUP) {
                tempModel.m_selected = false;
            }
        }
    }else {
        STMakeupDataModel *tempModel = _m_bmpTypeArr[0];
        if (tempModel.m_selected) {
            [[UIApplication sharedApplication].keyWindow makeToast:NSLocalizedString(@"请先取消整妆", nil)];
            return;
        }
        
    }
    _m_curModel = model;
    [self backToPreView:NO];
    [self updateUIsWithModel:model];
    [_m_bmpDetailColV didSelectedBmpType:model];
    if (self.delegate) {
        [self.delegate didSelectedCellModel:model];
    }
}

#pragma STBMPDetailColVDelegate
- (void)cleanMakeup{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cleanMakeUp)]) {
        [self.delegate cleanMakeUp];
    }
}

- (void)zeroSelectedModels {
    [_m_backBtn setBackgroundImage:[UIImage imageNamed:_m_curModel.m_iconDefault] forState:UIControlStateNormal];
    for (int i = STBMPTYPE_WHOLEMAKEUP; i < STBMPTYPE_EYE_BALL; i ++) {
        _m_bmpTypeArr[i].m_selected = NO;;
    }
    [_m_bmpTypeColv reloadData];
}

- (void)didSelectedModelByManu{
    [self.delegate didSelectedModelByManu];
}

- (void)didSelectedModel:(STMakeupDataModel *)model toTop:(BOOL)toTop{
    _m_curModel = _m_bmpTypeArr[(int)model.m_bmpType];
    if (model.m_selected && model.m_index != 0) {
        _m_curModel.m_selected = YES;
    }else{
        _m_curModel.m_selected = NO;
    }
    [self updateUIsWithModel:_m_curModel];
    [_m_bmpTypeColv reloadData];
    if (self.delegate && toTop) {
        [self.delegate didSelectedDetailModel:model];
    }
}

- (void)resetUis{
    for (STMakeupDataModel *model in _m_bmpTypeArr) {
        model.m_selected = NO;
    }
    [_m_bmpTypeColv reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"resetUIs" object:nil];
}


- (void)updateWholemakeup:(STMakeupDataModel *)model currentValue:(float)value{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(updateWholemakeup:currentValue:)]) {
        [self.delegate updateWholemakeup:model currentValue:value];
    }
}

@end
