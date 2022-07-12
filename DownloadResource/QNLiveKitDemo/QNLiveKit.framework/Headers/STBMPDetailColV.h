//
//  STBMPDetailColV.h
//  SenseMeEffects
//
//  Created by sensetimesunjian on 2019/5/10.
//  Copyright © 2019 SenseTime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMakeupDataModel.h"
#import "STParamUtil.h"

@protocol STBMPDetailColVDelegate <NSObject>

- (void)cleanMakeup;

- (void)zeroSelectedModels;

- (void)didSelectedModel:(STMakeupDataModel *)model toTop:(BOOL)toTop;

- (void)didSelectedModelByManu;

- (void)updateWholemakeup:(STMakeupDataModel *)model currentValue:(float)value;

@end

@interface STBMPDetailColV : UIView<UICollectionViewDelegate, UICollectionViewDataSource>

//models
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

//views
@property (nonatomic, strong) UICollectionView *m_bmpDtColV;

@property (nonatomic, weak) id<STBMPDetailColVDelegate> delegate;

@property (nonatomic, copy) void(^STBmpDetailBlock)(float value);

@property (nonatomic, assign) STBeautyType wholeBeautyType;

@property (nonatomic, strong) NSMutableDictionary <NSNumber *, NSMutableArray *>* defaultMakeups;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)didSelectedBmpType:(STMakeupDataModel *)model;

- (void)wholeMakeUp:(STBeautyType)beautyType ;

- (void)clearMakeUp;

- (void)reload;

- (void)restorePreSelectedMakeUps:(NSSet *)array;

- (void)updateMakeupValue:(NSSet *)array makeupValue:(float)value;

- (void)zeroMakeUp;

@end

