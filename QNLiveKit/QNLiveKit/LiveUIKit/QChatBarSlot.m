//
//  QChatBarSlot.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/19.
//

#import "QChatBarSlot.h"

@implementation QChatBarSlot

//默认
- (void)createDefaultView:(CGRect)frame onView:(UIView *)onView {

    UIButton *button = [[UIButton alloc]initWithFrame:frame];
    [button setImage:[UIImage imageNamed:@"chat_input_bar"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [onView addSubview:button];
}

- (void)click:(UIButton *)button {
    if (self.clickBlock) {
        self.clickBlock(YES);
    }
}

@end
