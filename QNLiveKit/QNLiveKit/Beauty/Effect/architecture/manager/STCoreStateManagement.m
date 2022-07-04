//
//  STCoreStateManagement.m
//  SenseMeEffects
//
//  Created by 马浩萌 on 2021/5/24.
//  Copyright © 2021 SenseTime. All rights reserved.
//

#import "STCoreStateManagement.h"

@implementation STCoreStateManagement

- (void)setFilterModel:(STCollectionViewDisplayModel *)filterModel {
    _filterModel = filterModel;
    if (self.valueChangeDelegate && [self.valueChangeDelegate respondsToSelector:@selector(coreStateManagement:filterModelValueChanged:)]) {
        [self.valueChangeDelegate coreStateManagement:self filterModelValueChanged:_filterModel];
    }
}

@end
