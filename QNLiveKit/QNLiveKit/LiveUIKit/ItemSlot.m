//
//  ItemSlot.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/31.
//

#import "ItemSlot.h"

@interface ItemSlot ()

@property (nonatomic, strong)UIButton *button;//房主头像

@end

@implementation ItemSlot

- (void)createDefaultView:(CGRect)frame onView:(UIView *)onView {
    self.button.frame = frame;
    [self.button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [onView addSubview:self.button];
}

- (void)normalImage:(NSString *)normalImage selectImage:(NSString *)selectImage {
    [self.button setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    [self.button setImage:[UIImage imageNamed:selectImage] forState:UIControlStateSelected];
}

- (void)click:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        button.frame = CGRectMake(button.frame.origin.x - 15, button.frame.origin.y, 70, 40);
    } else {
        button.frame = CGRectMake(button.frame.origin.x + 15, button.frame.origin.y, 40, 40);
    }
    if (self.clickBlock) {
        self.clickBlock(button.selected);
    }
}

- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc]init];
    }
    return _button;
}

//自定义
- (void)createCustomView:(UIView *)view onView:(UIView *)onView {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click)];
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:tap];
    
    [onView addSubview:view];
    
}

@end
