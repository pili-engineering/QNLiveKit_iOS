//
//  LinkStateSlot.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/7.
//

#import "LinkStateSlot.h"

@interface LinkStateSlot ()

@property (nonatomic, strong) UIView *view;

@property (nonatomic, strong) UIImageView *avatarImage;

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIButton *microphoneButton;

@end

@implementation LinkStateSlot

//默认
- (void)createDefaultView:(CGRect)frame onView:(UIView *)onView {
    
    self.view = [[UIView alloc] initWithFrame:frame];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.backgroundColor = [[UIColor colorWithHexString:@"F2F2F2"] CGColor];
    self.view.layer.cornerRadius = 15;
    
    self.avatarImage = [[UIImageView alloc]initWithFrame:CGRectMake((frame.size.width - 56)/2, 50, 56, 56)];
    [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:QN_User_avatar] placeholderImage:[UIImage imageNamed:@"titleImage"]];
    [self.view addSubview:self.avatarImage];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, frame.size.width, 20)];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = [UIColor colorWithRed:0.4 green:0.5 blue:0.4 alpha:1];
    self.label.text = @"连麦通话中...";
    self.label.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:self.label];
    
    self.closeButton = [[UIButton alloc]initWithFrame:CGRectMake((frame.size.width - 130)/2, 170, 130, 40)];
    [self.closeButton setImage:[UIImage imageNamed:@"end_link"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
    
    self.microphoneButton = [[UIButton alloc]initWithFrame:CGRectMake((frame.size.width - 130)/2 + 150, 170, 40, 40)];
    [self.microphoneButton setImage:[UIImage imageNamed:@"microphone_on"] forState:UIControlStateNormal];
    [self.microphoneButton setImage:[UIImage imageNamed:@"microphone_off"] forState:UIControlStateSelected];
    [self.microphoneButton addTarget:self action:@selector(microphoneClick:) forControlEvents:UIControlEventTouchUpInside];
    self.microphoneButton.layer.cornerRadius = 20;
    self.microphoneButton.clipsToBounds = YES;
    [self.view addSubview:self.microphoneButton];
    
    [onView addSubview:self.view];
}

- (void)microphoneClick:(UIButton *)button {
    button.selected = !button.selected;
    if (self.microphoneBlock) {
        self.microphoneBlock(button.selected);
    }
}

- (void)click {
    [self.view removeFromSuperview];
    if (self.clickBlock) {
        self.clickBlock();
    }
}
@end
