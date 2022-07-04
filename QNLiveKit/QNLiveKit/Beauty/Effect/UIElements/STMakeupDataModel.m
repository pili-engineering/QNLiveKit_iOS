//
//  STBMPModel.m
//  SenseMeEffects
//
//  Created by sensetimesunjian on 2019/5/10.
//  Copyright © 2019 SenseTime. All rights reserved.
//

#import "STMakeupDataModel.h"

@implementation STMakeupDataModel

- (instancetype)init{
    if (self = [super init]) {
        return self;
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone{
    STMakeupDataModel *model = [[STMakeupDataModel allocWithZone:zone] init];
    model.m_material = self.m_material;
    model.m_thumbImage = self.m_thumbImage;
    model.m_iconDefault = self.m_iconDefault;
    model.m_iconHighlight = self.m_iconHighlight;
    model.m_name = self.m_name;
    model.m_zipPath = self.m_zipPath;
    model.m_selected = self.m_selected;
    model.m_bmpType = self.m_bmpType;
    model.m_index = self.m_index;
    model.m_bmpStrength = self.m_bmpStrength;
    model.m_fromOnLine = self.m_fromOnLine;
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    STMakeupDataModel *model = [[STMakeupDataModel allocWithZone:zone] init];
    model.m_material = self.m_material;
    model.m_thumbImage = self.m_thumbImage;
    model.m_iconDefault = self.m_iconDefault;
    model.m_iconHighlight = self.m_iconHighlight;
    model.m_name = self.m_name;
    model.m_zipPath = self.m_zipPath;
    model.m_selected = self.m_selected;
    model.m_bmpType = self.m_bmpType;
    model.m_index = self.m_index;
    model.m_bmpStrength = self.m_bmpStrength;
    model.m_fromOnLine = self.m_fromOnLine;
    return model;
}

@end
