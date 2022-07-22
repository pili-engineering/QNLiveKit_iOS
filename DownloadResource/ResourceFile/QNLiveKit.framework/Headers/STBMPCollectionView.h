//
//  STBeautyMakeUpCollectionView.h
//  SenseMeEffects
//
//  Created by sensetimesunjian on 2019/5/10.
//  Copyright © 2019 SenseTime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STBMPDetailColV.h"
#import "STParamUtil.h"


@protocol STBMPCollectionViewDelegate <NSObject>

- (void)cleanMakeUp;

- (void)didSelectedCellModel:(STMakeupDataModel *)model;

- (void)didSelectedDetailModel:(STMakeupDataModel *)model;

- (void)didSelectedModelByManu;

- (void)backToMainView;

- (void)updateWholemakeup:(STMakeupDataModel *)model currentValue:(float)value;

@end

@interface STBMPCollectionView : UIView

@property (nonatomic, strong) STBMPDetailColV *m_bmpDetailColV;

@property (nonatomic, weak) id<STBMPCollectionViewDelegate> delegate;

@property (nonatomic, copy) void(^BMPCollectionViewBlock)(float value);

- (instancetype)initWithFrame:(CGRect)frame;

- (void)backToMenu;

- (void)wholeMakeUp:(STBeautyType)beautyType;

- (void)clearMakeUp;

- (void)resetUis;

- (void)zeroMakeUp;

@end
