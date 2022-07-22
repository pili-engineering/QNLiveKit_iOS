//
//  STCoreStateManagementFilterModel.h
//  SenseMeEffects
//
//  Created by 马浩萌 on 2021/5/24.
//  Copyright © 2021 SenseTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STParamUtil.h" // TODO: view层应拆分出来
#import "STCoreStateManagementModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface STCoreStateManagementFilterModel : STCoreStateManagementModel

@property (nonatomic,   copy) NSString *strPath;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic,   copy) NSString *strName;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) STEffectsType modelType;
@property (nonatomic, assign) float value;

@end

NS_ASSUME_NONNULL_END
