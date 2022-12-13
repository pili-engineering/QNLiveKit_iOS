//
//  STBMPDetailColVCell.h
//  SenseMeEffects
//
//  Created by sensetimesunjian on 2019/5/10.
//  Copyright © 2019 SenseTime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMakeupDataModel.h"

@interface STBMPDetailColVCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *m_icon;
@property (nonatomic, strong) UIImageView *m_download;
@property (nonatomic, strong) UIImageView *m_downloading;
@property (nonatomic, strong) UILabel *m_labelName;

- (void)setName:(NSString *)name;

- (void)setIcon:(id)icon;

- (void)setDidSelected:(BOOL)didSelected;

- (void)setState:(STState)state;

@end

