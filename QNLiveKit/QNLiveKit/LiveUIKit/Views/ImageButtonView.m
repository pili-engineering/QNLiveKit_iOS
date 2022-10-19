//
//  ImageButtonView.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/31.
//

#import "ImageButtonView.h"

@interface ImageButtonView ()

@property (nonatomic, strong)UIButton *button;

@end

@implementation ImageButtonView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 55, 55)];
        if (frame.size.width > 0) {
            self.button.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        }
        [self.button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
    }
    return self;
}

- (void)bundleNormalImage:(NSString *)normalImage selectImage:(NSString *)selectImage {
    [self.button setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    [self.button setImage:[UIImage imageNamed:selectImage] forState:UIControlStateSelected];
}

- (void)normalImage:(NSString *)normalImage selectImage:(NSString *)selectImage {
    [self.button setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    [self.button setImage:[UIImage imageNamed:selectImage] forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected {
    self.button.selected = selected;
}

- (void)click:(UIButton *)button {
    button.selected = !button.selected;
    if (self.clickBlock) {
        self.clickBlock(button.selected);
    }
}

@end
