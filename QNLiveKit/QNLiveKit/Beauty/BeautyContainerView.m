//
//  BeautyContainerView.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/30.
//

#import "BeautyContainerView.h"
#import "STScrollTitleView.h"
#import "STBMPCollectionView.h"
#import "STFilterView.h"

@interface BeautyContainerView ()

@property (nonatomic, strong) STScrollTitleView *beautyScrollTitleViewNew;

@property (nonatomic, strong) UIView *filterCategoryView;

@property (nonatomic, strong) STBMPCollectionView *bmpColView;

@property (nonatomic, strong) STFilterView *filterView;

@property (nonatomic, strong) STNewBeautyCollectionView *beautyCollectionView;

@end

@implementation BeautyContainerView

//- (instancetype)init {
//    if (self = [super init]) {
//        self.frame = CGRectMake(0, SCREEN_H - 260, SCREEN_W, 260);
//        self.backgroundColor = [UIColor clearColor];
//        [self addSubview:self.beautyScrollTitleViewNew];
//        
//        UIView *whiteLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_W, 1)];
//        whiteLineView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
//        [self addSubview:whiteLineView];
//        
//        [self addSubview:self.filterCategoryView];
//        [self addSubview:self.filterView];
//        [self addSubview:self.bmpColView];
//        [self addSubview:self.beautyCollectionView];
//        
//        [self.arrBeautyViews addObject:self.filterCategoryView];
//        [self.arrBeautyViews addObject:self.filterView];
//        [self.arrBeautyViews addObject:self.beautyCollectionView];
//    }
//    return self;
//}
//
//- (STNewBeautyCollectionView *)beautyCollectionView {
//    if (!_beautyCollectionView) {
//        STWeakSelf;
//        _beautyCollectionView = [[STNewBeautyCollectionView alloc] initWithFrame:CGRectMake(0, 41, SCREEN_WIDTH, 220) models:self.baseBeautyModels delegateBlock:^(STNewBeautyCollectionViewModel *model) {
//            
//            [weakSelf handleBeautyTypeChanged:model];
//        }];
//        _beautyCollectionView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
//        [_beautyCollectionView reloadData];
//    }
//    return _beautyCollectionView;
//}
//
//- (STFilterView *)filterView {
//    
//    if (!_filterView) {
//        
//        _filterView = [[STFilterView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 41, SCREEN_WIDTH, 300)];
//        _filterView.leftView.imageView.image = [UIImage imageNamed:@"still_life_highlighted"];
//        _filterView.leftView.titleLabel.text = @"静物";
//        _filterView.leftView.titleLabel.textColor = [UIColor whiteColor];
//        
//        _filterView.filterCollectionView.arrSceneryFilterModels = self.filterDataSources[@(STEffectsTypeFilterScenery)];
//        _filterView.filterCollectionView.arrPortraitFilterModels = self.filterDataSources[@(STEffectsTypeFilterPortrait)];
//        _filterView.filterCollectionView.arrStillLifeFilterModels = self.filterDataSources[@(STEffectsTypeFilterStillLife)];
//        _filterView.filterCollectionView.arrDeliciousFoodFilterModels = self.filterDataSources[@(STEffectsTypeFilterDeliciousFood)];
//        
//        STWeakSelf;
//        _filterView.filterCollectionView.delegateBlock = ^(STCollectionViewDisplayModel *model) {
//            [weakSelf manuHandleFilter];
//            [weakSelf handleFilterChanged:model];
//        };
//        _filterView.block = ^{
//            [UIView animateWithDuration:0.5 animations:^{
//                weakSelf.filterCategoryView.frame = CGRectMake(0, weakSelf.filterCategoryView.frame.origin.y, SCREEN_WIDTH, 300);
//                weakSelf.filterView.frame = CGRectMake(SCREEN_WIDTH, weakSelf.filterView.frame.origin.y, SCREEN_WIDTH, 300);
//            }];
//            weakSelf.filterStrengthView.hidden = YES;
//        };
//    }
//    return _filterView;
//}
//
//- (STScrollTitleView *)beautyScrollTitleViewNew {
//    if (!_beautyScrollTitleViewNew) {
//        
//        NSArray *beautyCategory = @[NSLocalizedString(@"整体效果", nil) ,
//                                    NSLocalizedString(@"基础美颜", nil),
//                                    NSLocalizedString(@"美形", nil),
//                                    NSLocalizedString(@"微整形", nil),
//                                    NSLocalizedString(@"美妆", nil),
//                                    NSLocalizedString(@"滤镜", nil),
//                                    NSLocalizedString(@"调整", nil)];
//        NSArray *beautyType = @[@(STEffectsTypeBeautyWholeMakeup),
//                                @(STEffectsTypeBeautyBase),
//                                @(STEffectsTypeBeautyShape),
//                                @(STEffectsTypeBeautyMicroSurgery),
//                                @(STEffectsTypeBeautyMakeUp),
//                                @(STEffectsTypeBeautyFilter),
//                                @(STEffectsTypeBeautyAdjust)];
//        
//        STWeakSelf;
//        _beautyScrollTitleViewNew = [[STScrollTitleView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40) titles:beautyCategory effectsType:beautyType autoIndex:0 titleOnClick:^(STTitleViewItem *titleView, NSInteger index, STEffectsType type) {
//            [weakSelf handleEffectsType:type];
//        }];
//        _beautyScrollTitleViewNew.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
//    }
//    return _beautyScrollTitleViewNew;
//}
//
//- (UIView *)filterCategoryView {
//    if (!_filterCategoryView) {
//        _filterCategoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 41, SCREEN_WIDTH, 300)];
//        _filterCategoryView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
//        STViewButton *portraitViewBtn = [[[NSBundle mainBundle] loadNibNamed:@"STViewButton" owner:nil options:nil] firstObject];
//        portraitViewBtn.tag = STEffectsTypeFilterPortrait;
//        portraitViewBtn.backgroundColor = [UIColor clearColor];
//        portraitViewBtn.frame =  CGRectMake(SCREEN_WIDTH / 2 - 143, 20, 40, 70);
//        portraitViewBtn.imageView.image = [UIImage imageNamed:@"portrait"];
//        portraitViewBtn.imageView.highlightedImage = [UIImage imageNamed:@"portrait_highlighted"];
//        portraitViewBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//        portraitViewBtn.titleLabel.textColor = [UIColor whiteColor];
//        portraitViewBtn.titleLabel.highlightedTextColor = [UIColor whiteColor];
//        portraitViewBtn.titleLabel.text =  NSLocalizedString(@"人物", nil);
//        
//        for (UIGestureRecognizer *recognizer in portraitViewBtn.gestureRecognizers) {
//            [portraitViewBtn removeGestureRecognizer:recognizer];
//        }
//        UITapGestureRecognizer *portraitRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchFilterType:)];
//        [portraitViewBtn addGestureRecognizer:portraitRecognizer];
//        [self.arrFilterCategoryViews addObject:portraitViewBtn];
//        [_filterCategoryView addSubview:portraitViewBtn];
//        
//        
//        
//        STViewButton *sceneryViewBtn = [[[NSBundle mainBundle] loadNibNamed:@"STViewButton" owner:nil options:nil] firstObject];
//        sceneryViewBtn.tag = STEffectsTypeFilterScenery;
//        sceneryViewBtn.backgroundColor = [UIColor clearColor];
//        sceneryViewBtn.frame =  CGRectMake(SCREEN_WIDTH / 2 - 60, 20, 40, 70);
//        sceneryViewBtn.imageView.image = [UIImage imageNamed:@"scenery"];
//        sceneryViewBtn.imageView.highlightedImage = [UIImage imageNamed:@"scenery_highlighted"];
//        sceneryViewBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//        sceneryViewBtn.titleLabel.textColor = [UIColor whiteColor];
//        sceneryViewBtn.titleLabel.highlightedTextColor = [UIColor whiteColor];
//        sceneryViewBtn.titleLabel.text = NSLocalizedString(@"风景", nil);
//        
//        for (UIGestureRecognizer *recognizer in sceneryViewBtn.gestureRecognizers) {
//            [sceneryViewBtn removeGestureRecognizer:recognizer];
//        }
//        UITapGestureRecognizer *sceneryRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchFilterType:)];
//        [sceneryViewBtn addGestureRecognizer:sceneryRecognizer];
//        [self.arrFilterCategoryViews addObject:sceneryViewBtn];
//        [_filterCategoryView addSubview:sceneryViewBtn];
//        STViewButton *stillLifeViewBtn = [[[NSBundle mainBundle] loadNibNamed:@"STViewButton" owner:nil options:nil] firstObject];
//        stillLifeViewBtn.tag = STEffectsTypeFilterStillLife;
//        stillLifeViewBtn.backgroundColor = [UIColor clearColor];
//        stillLifeViewBtn.frame =  CGRectMake(SCREEN_WIDTH / 2 + 27, 20, 40, 70);
//        stillLifeViewBtn.imageView.image = [UIImage imageNamed:@"still_life"];
//        stillLifeViewBtn.imageView.highlightedImage = [UIImage imageNamed:@"still_life_highlighted"];
//        stillLifeViewBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//        stillLifeViewBtn.titleLabel.textColor = [UIColor whiteColor];
//        stillLifeViewBtn.titleLabel.highlightedTextColor = [UIColor whiteColor];
//        stillLifeViewBtn.titleLabel.text = NSLocalizedString(@"静物", nil);
//        for (UIGestureRecognizer *recognizer in stillLifeViewBtn.gestureRecognizers) {
//            [stillLifeViewBtn removeGestureRecognizer:recognizer];
//        }
//        UITapGestureRecognizer *stillLifeRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchFilterType:)];
//        [stillLifeViewBtn addGestureRecognizer:stillLifeRecognizer];
//        [self.arrFilterCategoryViews addObject:stillLifeViewBtn];
//        [_filterCategoryView addSubview:stillLifeViewBtn];
//        STViewButton *deliciousFoodViewBtn = [[[NSBundle mainBundle] loadNibNamed:@"STViewButton" owner:nil options:nil] firstObject];
//        deliciousFoodViewBtn.tag = STEffectsTypeFilterDeliciousFood;
//        deliciousFoodViewBtn.backgroundColor = [UIColor clearColor];
//        deliciousFoodViewBtn.frame =  CGRectMake(SCREEN_WIDTH / 2 + 110, 20, 40, 70);
//        deliciousFoodViewBtn.imageView.image = [UIImage imageNamed:@"delicious_food"];
//        deliciousFoodViewBtn.imageView.highlightedImage = [UIImage imageNamed:@"delicious_food_highlighted"];
//        deliciousFoodViewBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//        deliciousFoodViewBtn.titleLabel.textColor = [UIColor whiteColor];
//        deliciousFoodViewBtn.titleLabel.highlightedTextColor = [UIColor whiteColor];
//        deliciousFoodViewBtn.titleLabel.text = NSLocalizedString(@"美食", nil);
//        
//        for (UIGestureRecognizer *recognizer in deliciousFoodViewBtn.gestureRecognizers) {
//            [deliciousFoodViewBtn removeGestureRecognizer:recognizer];
//        }
//        UITapGestureRecognizer *deliciousFoodRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchFilterType:)];
//        [deliciousFoodViewBtn addGestureRecognizer:deliciousFoodRecognizer];
//        [self.arrFilterCategoryViews addObject:deliciousFoodViewBtn];
//        [_filterCategoryView addSubview:deliciousFoodViewBtn];
//        
//    }
//    return _filterCategoryView;
//}
//
///// 美妆效果列表 view
//- (STBMPCollectionView *)bmpColView{
//    if (!_bmpColView) {
//        _bmpColView = [[STBMPCollectionView alloc] initWithFrame:CGRectMake(0, 41, SCREEN_WIDTH, 220)];
//        _bmpColView.delegate = self;
//        _bmpColView.hidden = YES;
//        _bmpStrenghView = [[STBmpStrengthView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 260 - 35.5, SCREEN_WIDTH, 35.5)];
//        _bmpStrenghView.backgroundColor = [UIColor clearColor];
//        _bmpStrenghView.hidden = YES;
//        _bmpStrenghView.delegate = self;
//        [self.view addSubview:_bmpStrenghView];
//    }
//    return _bmpColView;
//}

@end
