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
@end

@implementation QNCreateLiveController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"live_bg"]];
    bg.frame = self.view.frame;
    [self.view addSubview:bg];
    
    [self titleTf];
    [self startButton];
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

//创建直播
- (void)createLive {
    QNCreateRoomParam *params = [QNCreateRoomParam new];
    params.title = self.titleTf.text;
//    params.notice = @"";
//    params.cover_url = @"";
//    params.extension = @"";
    
    [QNLiveRoomEngine createRoom:params callBack:^(QNLiveRoomInfo * _Nonnull roomInfo) {
        QNLiveController *vc = [QNLiveController new];
        vc.roomInfo = roomInfo;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }];
}

@end
