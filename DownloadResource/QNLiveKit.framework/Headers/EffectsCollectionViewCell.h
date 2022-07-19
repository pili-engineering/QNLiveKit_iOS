//
//  EffectsCollectionViewCell.h
//  SenseMeEffects
//
//  Created by Lin Sun on 2018/12/8.
//  Copyright © 2018 SenseTime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SenseArSourceService.h"
#import "STParamUtil.h"

typedef enum : NSUInteger {
    NotDownloaded = 0,
    IsDownloading,
    Downloaded,
    IsSelected
} ModelState;

@interface EffectsCollectionViewCellModel : NSObject
@property (nonatomic , assign) int packageId;
@property (nonatomic , assign) ModelState state;
@property (nonatomic , assign) int indexOfItem;
@property (nonatomic , assign) STEffectsType iEffetsType;
@property (nonatomic , strong) UIImage *imageThumb;

@property (nonatomic , strong) SenseArMaterial *material;
@property (nonatomic , copy) NSString *strMaterialPath;

@end

@interface EffectsCollectionViewCell : UICollectionViewCell

@property (nonatomic , strong) EffectsCollectionViewCellModel *model;

@property (strong, nonatomic) UIImageView *thumbView;
@property (strong, nonatomic) UIImageView *loadingView;
@property (strong, nonatomic) UIImageView *downloadSign;


@end


