//
//  QNInternalViewSlot.m
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/31.
//

#import "QNInternalViewSlot.h"

@implementation QNInternalViewSlot

- (UIView *)createDefaultViewWithClient:(QNLiveRoomClient *)client onView:(UIView *)onView{
    return [UIView new];
}

- (void)createCustomView:(UIView *)view client:(QNLiveRoomClient *)client onView:(UIView *)onView{
    
}

@end
