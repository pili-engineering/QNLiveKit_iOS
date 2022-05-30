//
//  QNBaseRTCController.m
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/30.
//

#import "QNBaseRTCController.h"

@interface QNBaseRTCController ()

@end

@implementation QNBaseRTCController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBG];
}

- (void)setupBG {
    self.renderBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.view insertSubview:self.renderBackgroundView atIndex:0];
    
    self.preview = [[QNGLKView alloc] init];
    self.preview.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [self.renderBackgroundView addSubview:self.preview];
}




@end
