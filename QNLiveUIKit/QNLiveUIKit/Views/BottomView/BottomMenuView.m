//
//  BottomMenuView.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/31.
//

#import "BottomMenuView.h"
#import "ImageButtonView.h"

static const CGFloat Slot_W = 55;//按钮宽

@interface BottomMenuView ()

//菜单列表
@property (nonatomic,copy)NSArray <ImageButtonView *> *slotList;

@end

@implementation BottomMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)updateWithSlotList:(NSArray<ImageButtonView *> *)slotList {
    self.slotList = slotList;
    CGFloat space = (self.frame.size.width - (Slot_W * self.slotList.count))/(self.slotList.count + 1);
    
    for (int i = 0; i < self.slotList.count; i++) {
        ImageButtonView *slot = self.slotList[i];
        CGRect slotFrame = CGRectMake(space + (Slot_W +space) * i, (self.frame.size.height - Slot_W)/2 , Slot_W, Slot_W);
        slot.frame = slotFrame;
        [self addSubview:slot];
    }
}

@end
