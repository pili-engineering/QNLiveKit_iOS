//
//  QNCreateLiveController.m
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/30.
//

#import "QNCreateLiveController.h"
#import <QNLiveKit/QNLiveKit.h>

@interface QNCreateLiveController ()
@property (nonatomic, strong) UITextField *titleTf;
@property (nonatomic, strong) QNGLKView *preview;//自己画面的预览视图
@property (nonatomic, strong) QNLivePushClient *pushClient;

@end

@implementation QNCreateLiveController

- (void)viewWillDisappear:(BOOL)animated {
    self.pushClient = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"live_bg"]];
    bg.frame = self.view.frame;
    [self.view addSubview:bg];
    
    self.preview = [[QNGLKView alloc] init];
    self.preview.frame = self.view.frame;
    [bg addSubview:self.preview];

    self.pushClient = [[QNLivePushClient alloc]init];
    [self.pushClient setLocalPreView:self.preview];
    
    [self titleTf];
    [self startButton];
    [self closeButton];
    
}

- (UITextField *)titleTf {
    if (!_titleTf) {
        _titleTf = [[UITextField alloc]initWithFrame:CGRectMake(30, 100, 200, 30)];
        _titleTf.font = [UIFont systemFontOfSize:15];
        _titleTf.textColor = [UIColor whiteColor];
        _titleTf.textAlignment = NSTextAlignmentLeft;
        NSAttributedString *placeHolderStr = [[NSAttributedString alloc]initWithString:@"请输入直播标题" attributes:@{
            NSForegroundColorAttributeName:[UIColor whiteColor],
            NSFontAttributeName:_titleTf.font
        }];
        _titleTf.attributedPlaceholder = placeHolderStr;
        [self.view addSubview:_titleTf];
        
    }
    return _titleTf;
}

- (void)startButton {
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake((kScreenWidth - 200)/2, kScreenHeight - 100, 200, 40)];
    button.clipsToBounds = YES;
    button.layer.cornerRadius = 20;
    [button setImage:[UIImage imageNamed:@"begin_live"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(createLive) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)closeButton {
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth - 40, 50, 20, 20)];
    button.clipsToBounds = YES;
    button.layer.cornerRadius = 20;
    [button setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//创建直播
- (void)createLive {
    QNCreateRoomParam *params = [QNCreateRoomParam new];
    params.title = self.titleTf.text;
//    params.notice = @"";
//    params.cover_url = @"";
//    params.extension = @"";
    
    [QNLiveRoomEngine createRoom:params callBack:^(QNLiveRoomInfo * _Nonnull roomInfo) {
        [self.pushClient enableCamera];
        QNLiveController *vc = [QNLiveController new];
        vc.roomInfo = roomInfo;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }];
}



@end
