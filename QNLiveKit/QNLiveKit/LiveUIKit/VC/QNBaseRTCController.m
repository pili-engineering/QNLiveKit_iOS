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
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"live_bg"]];
    bg.frame = self.view.frame;
    [self.view addSubview:bg];
    
    self.renderBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H)];
    [self.view insertSubview:self.renderBackgroundView atIndex:1];
    
    self.preview = [[QNGLKView alloc] init];
    self.preview.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
    [self.renderBackgroundView addSubview:self.preview];
}

@end
