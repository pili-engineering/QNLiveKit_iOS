//
//  BottomMenuSlot.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/31.
//

#import "BottomMenuSlot.h"
#import "ImageButtonComponent.h"

static const CGFloat Slot_W = 55;//按钮宽

@implementation BottomMenuSlot

- (void)createDefaultView:(CGRect)frame onView:(UIView *)onView {
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor clearColor];
    [onView addSubview:view];
    
    CGFloat space = (frame.size.width - (Slot_W * self.slotList.count))/(self.slotList.count + 1);
    
    for (int i = 0; i < self.slotList.count; i++) {
        ImageButtonComponent *slot = self.slotList[i];
        CGRect slotFrame = CGRectMake(space + (Slot_W +space) * i, (frame.size.height - Slot_W)/2 , Slot_W, Slot_W);
        [slot createDefaultView:slotFrame onView:view];
    }
}

@end
