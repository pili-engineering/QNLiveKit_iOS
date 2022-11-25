//
//  LiveBottomMoreView.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/10/19.
//

#import "LiveBottomMoreView.h"
#import "BottomMenuView.h"
#import "ImageButtonView.h"
@interface LiveBottomMoreView ()

@property (nonatomic, assign) BOOL beauty;

@end

@implementation LiveBottomMoreView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        [self createUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame beauty:(BOOL)beauty {
    if (self = [super initWithFrame:frame]) {
        self.beauty = beauty;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        [self createUI];
    }
    return self;
}

- (void)createUI {
    BottomMenuView *bottomMenuView;
    if (self.beauty) {
        bottomMenuView = [[BottomMenuView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    } else {
        bottomMenuView = [[BottomMenuView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width * 3 / 5, self.frame.size.height)];
    }
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
    
    
    //摄像头反转
    ImageButtonView *camera = [[ImageButtonView alloc]initWithFrame:CGRectZero];
    [camera bundleNormalImage:@"camera_change" selectImage:@"camera_change"];
    camera.clickBlock = ^(BOOL selected) {
        if (weakSelf.cameraChangeBlock) {
            weakSelf.cameraChangeBlock();
        }
    };
    [slotList addObject:camera];
    
    //开关麦克风
    ImageButtonView *mic = [[ImageButtonView alloc]initWithFrame:CGRectZero];
    [mic bundleNormalImage:@"mic_on" selectImage:@"mic_off"];
    mic.clickBlock = ^(BOOL selected) {
        if (weakSelf.microphoneBlock) {
            weakSelf.microphoneBlock(selected);
        }
    };
    [slotList addObject:mic];
    
    //画面镜像
    ImageButtonView *mirror = [[ImageButtonView alloc]initWithFrame:CGRectZero];
    [mirror bundleNormalImage:@"camera_mirror" selectImage:@"camera_mirror"];
    mirror.clickBlock = ^(BOOL selected) {
        if (weakSelf.cameraMirrorBlock) {
            weakSelf.cameraMirrorBlock(selected);
        }
    };
    [slotList addObject:mirror];
    
    if (self.beauty) {
    //美颜
        ImageButtonView *beauty = [[ImageButtonView alloc]initWithFrame:CGRectZero];
        [beauty bundleNormalImage:@"icon_beauty" selectImage:@"icon_beauty"];
        beauty.clickBlock = ^(BOOL selected) {
            if (weakSelf.beautyBlock) {
                weakSelf.beautyBlock();
            }
            [weakSelf removeFromSuperview];
        };
        [slotList addObject:beauty];
        
        //特效
        ImageButtonView *specialEffects = [[ImageButtonView alloc]initWithFrame:CGRectZero];
        [specialEffects bundleNormalImage:@"icon_effects" selectImage:@"icon_effects"];
        specialEffects.clickBlock = ^(BOOL selected) {
            if (weakSelf.effectsBlock) {
                weakSelf.effectsBlock();
            }
            [weakSelf removeFromSuperview];
        };
        [slotList addObject:specialEffects];
    }
        
    [bottomMenuView updateWithSlotList:slotList.copy];
    
}

- (void)closeClick {
    [self removeFromSuperview];
}

@end
