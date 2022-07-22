//
//  STSlideView.h
//  SenseMeEffects
//
//  Created by zhangbaoshan on 2021/3/13.
//  Copyright © 2021 SenseTime. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface STSlideView : UIView
@property (strong, nonatomic)  UILabel  *makeupLabel;
@property (strong, nonatomic)  UILabel  *filterLabel;
@property (strong, nonatomic)  UISlider *makeupSlide;
@property (strong, nonatomic)  UISlider *filterSlide;
@property (strong, nonatomic)  UILabel  *makeupValue;
@property (strong, nonatomic)  UILabel  *filterValue;

@end

NS_ASSUME_NONNULL_END
