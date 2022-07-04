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
@property (weak, nonatomic) IBOutlet UILabel  *makeupLabel;
@property (weak, nonatomic) IBOutlet UILabel  *filterLabel;
@property (weak, nonatomic) IBOutlet UISlider *makeupSlide;
@property (weak, nonatomic) IBOutlet UISlider *filterSlide;
@property (weak, nonatomic) IBOutlet UILabel  *makeupValue;
@property (weak, nonatomic) IBOutlet UILabel  *filterValue;

@end

NS_ASSUME_NONNULL_END
