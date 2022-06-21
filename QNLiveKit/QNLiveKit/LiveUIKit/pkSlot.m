//
//  pkSlot.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/21.
//

#import "pkSlot.h"

@interface pkSlot ()

@property (nonatomic, strong)UIButton *button;

@end

@implementation pkSlot

- (void)createDefaultView:(CGRect)frame onView:(UIView *)onView {
    self.button.frame = frame;
    [self.button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [onView addSubview:self.button];
}

- (void)normalImage:(NSString *)normalImage selectImage:(NSString *)selectImage {
    [self.button setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    [self.button setImage:[UIImage imageNamed:selectImage] forState:UIControlStateSelected];
}



@end
