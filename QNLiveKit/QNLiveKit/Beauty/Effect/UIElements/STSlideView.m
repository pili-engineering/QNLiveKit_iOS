//
//  STSlideView.m
//  SenseMeEffects
//
//  Created by zhangbaoshan on 2021/3/13.
//  Copyright © 2021 SenseTime. All rights reserved.
//

#import "STSlideView.h"

@interface STSlideView ()

@end

@implementation STSlideView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self makeupLabel];
        [self filterLabel];
        [self makeupSlide];
        [self filterSlide];
        [self makeupValue];
        [self filterValue];
    }
    return self;
}

- (UILabel *)makeupLabel {
    if (!_makeupLabel) {
        _makeupLabel = [[UILabel alloc]init];
        _makeupLabel.textColor = [UIColor whiteColor];
        _makeupLabel.font = [UIFont systemFontOfSize:14];
        _makeupLabel.text = @"美妆";
        [self addSubview:_makeupLabel];
        
        [_makeupLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.top.equalTo(self).offset(10);
        }];
    }
    return _makeupLabel;
}

- (UILabel *)filterLabel {
    if (!_filterLabel) {
        _filterLabel = [[UILabel alloc]init];
        _filterLabel.textColor = [UIColor whiteColor];
        _filterLabel.font = [UIFont systemFontOfSize:14];
        _filterLabel.text = @"滤镜";
        [self addSubview:_filterLabel];
        
        [_filterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.top.equalTo(self.makeupLabel.mas_bottom).offset(20);
        }];
    }
    return _filterLabel;
}

- (UISlider *)makeupSlide {
    if (!_makeupSlide) {
        _makeupSlide = [[UISlider alloc]init];
        _makeupSlide.minimumValue = 0.0;
        _makeupSlide.maximumValue = 100.0;
        [_makeupSlide setValue:85.0];
        _makeupSlide.minimumTrackTintColor = [UIColor blueColor];
        _makeupSlide.maximumTrackTintColor = [UIColor whiteColor];
//        _makeupSlide.isContinuous = true;
        [self addSubview:_makeupSlide];
        
        [_makeupSlide mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.makeupLabel.mas_right).offset(10);
            make.centerY.equalTo(self.makeupLabel);
            make.right.equalTo(self.mas_right).offset(-60);
        }];
    }
    return _makeupSlide;
}

- (UISlider *)filterSlide {
    if (!_filterSlide) {
        _filterSlide = [[UISlider alloc]init];
        _filterSlide.minimumValue = 0.0;
        _filterSlide.maximumValue = 100.0;
        [_filterSlide setValue:85.0];
        _filterSlide.minimumTrackTintColor = [UIColor blueColor];
        _filterSlide.maximumTrackTintColor = [UIColor whiteColor];
//        _filterSlide.isContinuous = true;
        [self addSubview:_filterSlide];
        
        [_filterSlide mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.filterLabel.mas_right).offset(10);
            make.centerY.equalTo(self.filterLabel);
            make.right.equalTo(self.mas_right).offset(-60);
        }];
    }
    return _filterSlide;
}

- (UILabel *)makeupValue {
    if (!_makeupValue) {
        _makeupValue = [[UILabel alloc]init];
        _makeupValue.textColor = [UIColor whiteColor];
        _makeupValue.font = [UIFont systemFontOfSize:14];
        _makeupValue.text = @"85";
        [self addSubview:_makeupValue];
        
        [_makeupValue mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.makeupSlide.mas_right).offset(15);
            make.centerY.equalTo(self.makeupLabel);
        }];
    }
    return _makeupValue;
}

- (UILabel *)filterValue {
    if (!_filterValue) {
        _filterValue = [[UILabel alloc]init];
        _filterValue.textColor = [UIColor whiteColor];
        _filterValue.font = [UIFont systemFontOfSize:14];
        _filterValue.text = @"85";
        [self addSubview:_filterValue];
        
        [_filterValue mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.filterSlide.mas_right).offset(15);
            make.centerY.equalTo(self.filterLabel);
        }];
    }
    return _filterValue;
}
@end
