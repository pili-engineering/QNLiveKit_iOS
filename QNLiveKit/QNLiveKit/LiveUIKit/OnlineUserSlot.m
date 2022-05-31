//
//  OnlineUserSlot.m
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/31.
//

#import "OnlineUserSlot.h"
#import "QNLiveRoomInfo.h"

static const CGFloat countLabel_H = 15;//数字高

@interface OnlineUserSlot ()

@property (nonatomic, strong)UILabel *countLabel;//房间人数

@end

@implementation OnlineUserSlot

//默认
- (void)createDefaultView:(CGRect)frame onView:(UIView *)onView {
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25].CGColor;
    view.layer.cornerRadius = frame.size.height/2;
    
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (frame.size.height - countLabel_H)/2, frame.size.width, countLabel_H)];
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    self.countLabel.textColor = [UIColor whiteColor];
    self.countLabel.font = [UIFont systemFontOfSize:14];
    [view addSubview:self.countLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click)];
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:tap];
    
    [onView addSubview:view];
}

- (void)click {
    if (self.clickBlock) {
        self.clickBlock();
    }
}

- (void)updateWith:(QNLiveRoomInfo *)roomInfo {
    self.countLabel.text = roomInfo.online_count ?: @"0";
}

//自定义
- (void)createCustomView:(UIView *)view onView:(UIView *)onView {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click)];
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:tap];
    
    [onView addSubview:view];
    
}


@end
