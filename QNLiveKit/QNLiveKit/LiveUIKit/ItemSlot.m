//
//  ItemSlot.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/31.
//

#import "ItemSlot.h"

@interface ItemSlot ()

@property (nonatomic, strong)UIButton *button;

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

- (void)setSelected:(BOOL)selected {
    self.button.selected = selected;
//    if (self.button.selected) {
//        self.button.frame = CGRectMake(self.button.frame.origin.x - 15, self.button.frame.origin.y, 70, 40);
//    } else {
//        self.button.frame = CGRectMake(self.button.frame.origin.x + 15, self.button.frame.origin.y, 40, 40);
//    }
}

- (void)click:(UIButton *)button {    
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
