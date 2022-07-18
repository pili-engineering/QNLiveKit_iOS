//
//  STCoreStateManagementValueChangeDelegate.h
//  SenseMeEffects
//
//  Created by 马浩萌 on 2021/5/24.
//  Copyright © 2021 SenseTime. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class STCoreStateManagement, STCollectionViewDisplayModel;

@protocol STCoreStateManagementValueChangeDelegate <NSObject>

@optional
- (void)coreStateManagement:(STCoreStateManagement *)management filterModelValueChanged:(STCollectionViewDisplayModel *)filterModel;

@end

NS_ASSUME_NONNULL_END
