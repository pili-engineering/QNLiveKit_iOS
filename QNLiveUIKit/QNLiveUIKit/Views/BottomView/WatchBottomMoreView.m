//
//  WatchBottomMoreView.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/10/19.
//

#import "WatchBottomMoreView.h"
#import "BottomMenuView.h"
#import "ImageButtonView.h"

@implementation WatchBottomMoreView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        [self createUI];
    }
    return self;
}

- (void)createUI {
    BottomMenuView *bottomMenuView = [[BottomMenuView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width/2, self.frame.size.height)];
    [self addSubview:bottomMenuView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, SCREEN_W, 20)];
    label.text = @"更多";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:14];
    [self addSubview:label];
    
    UIButton *closeButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_W - 40, 25, 20, 20)];
    [closeButton setImage:[UIImage imageNamed:@"white_close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    
    NSMutableArray *slotList = [NSMutableArray array];
    __weak typeof(self)weakSelf = self;
    
    //赠送礼物
    ImageButtonView *gift = [[ImageButtonView alloc]initWithFrame:CGRectZero];
    [gift bundleNormalImage:@"send_gift" selectImage:@"send_gift"];
    gift.clickBlock = ^(BOOL selected) {
        if (weakSelf.giftBlock) {
            weakSelf.giftBlock();
        }
        [weakSelf removeFromSuperview];
    };
    _gift = gift;
    [slotList addObject:gift];
    
    //连麦
    ImageButtonView *link = [[ImageButtonView alloc]initWithFrame:CGRectZero];
    [link bundleNormalImage:@"apply_link" selectImage:@"apply_link"];
    link.clickBlock = ^(BOOL selected) {
        if (weakSelf.applyLinkBlock) {
            weakSelf.applyLinkBlock();
        }
        [weakSelf removeFromSuperview];
    };
    [slotList addObject:link];
    _link = link;
    [bottomMenuView updateWithSlotList:slotList];
    
}

- (void)closeClick {
    [self removeFromSuperview];
}


@end
