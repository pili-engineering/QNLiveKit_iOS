//
//  CreateBeautyLiveController.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/18.
//

#import "CreateBeautyLiveController.h"
#import "QRenderView.h"
#import "BeautyLiveViewController.h"
#import "DateTimePickerView.h"

@interface CreateBeautyLiveController () <QNLocalVideoTrackDelegate>
@property (nonatomic, strong) UITextField *titleTf;
@property (nonatomic, strong) UITextField *commendTf;
@property (nonatomic, strong) UIButton *nowButton;
@property (nonatomic, strong) UIButton *waitButton;
@property (nonatomic, strong) UITextField *liveTimeTf;
@property (nonatomic, strong) DateTimePickerView * dateTimePickerView;
@end

@implementation CreateBeautyLiveController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[QLive createPusherClient] enableCamera:nil renderView:self.preview];

    [[QLive createPusherClient] setVideoFrameListener:self];
//    UIImageView *bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"live_bg"]];
//    bg.frame = self.view.frame;
//    [self.view addSubview:bg];
//    [self.view sendSubviewToBack:bg];
//    
//    [bg addSubview:self.preview];
        
    [self titleTf];
    [self commendTf];
    [self selectPoint];
    [self liveTimeTf];
#ifdef useBeauty
    [self beautyButton];
#endif
    
    [self startButton];
    [self turnAroundButton];
    [self closeButton];
}


- (void)localVideoTrack:(QNLocalVideoTrack *)localVideoTrack didGetPixelBuffer:(CVPixelBufferRef)pixelBuffer {
#ifdef useBeauty
    
    QNCameraVideoTrack *track = (QNCameraVideoTrack *)localVideoTrack;
    
    static st_mobile_human_action_t result;
    static st_mobile_animal_face_t animalResult;
    QNAllResult res;
    memset(&res, 0, sizeof(res));
    res.animal_result = &animalResult;
    res.humanResult = &result;
    
//    [self updateFirstEnterUI];
    
    QNDetectConfig detectConfig;
    memset(&detectConfig, 0, sizeof(QNDetectConfig));
    detectConfig.humanConfig = [self.effectManager getEffectDetectConfig];
    detectConfig.animalConfig = [self.effectManager getEffectAnimalDetectConfig];
    
    [self.detector detect:pixelBuffer cameraOrientation:track.videoOrientation detectConfig:detectConfig allResult:&res];
    [self.effectManager processBuffer:pixelBuffer cameraOrientation:track.videoOrientation detectResult:&res];
#endif
}

- (UITextField *)titleTf {
    if (!_titleTf) {
        _titleTf = [[UITextField alloc]initWithFrame:CGRectMake(30, 100, 200, 30)];
        _titleTf.font = [UIFont systemFontOfSize:18];
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

- (UITextField *)commendTf {
    if (!_commendTf) {
        _commendTf = [[UITextField alloc]initWithFrame:CGRectMake(30, 150, 200, 30)];
        _commendTf.font = [UIFont systemFontOfSize:15];
        _commendTf.textColor = [UIColor whiteColor];
        _commendTf.textAlignment = NSTextAlignmentLeft;
        NSAttributedString *placeHolderStr = [[NSAttributedString alloc]initWithString:@"请输入直播公告" attributes:@{
            NSForegroundColorAttributeName:[UIColor whiteColor],
            NSFontAttributeName:_commendTf.font
        }];
        _commendTf.attributedPlaceholder = placeHolderStr;
        [self.view addSubview:_commendTf];
        
    }
    return _commendTf;
}

#ifdef useBeauty
//美颜
- (void)beautyButtonClick {
    [self clickBottomViewButton:self.beautyBtn];
}
#endif
//翻转摄像头
- (void)turnAroundButtonClick {
    [[QNLivePushClient createPushClient] switchCamera];
}

- (void)beautyButton {
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_W - 200)/2 - 60, SCREEN_H - 100, 40, 40)];
    [button setImage:[UIImage imageNamed:@"create_beauty"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(beautyButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)selectPoint {
    NSArray *selectArr = @[@"live_time", @"now_select",@"wait_select"];
    NSArray *disSelectArr = @[@"live_time",@"now_disSelect",@"wait_disSelect"];
    for (int i = 0; i < 3; i ++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(20 + (80 + 30) *i, 200, 80, 30)];
        [button setImage:[UIImage imageNamed:disSelectArr[i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:selectArr[i]] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(livebeginSelect:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        if (i == 1) {
            self.nowButton = button;
        }
        if (i == 2) {
            self.waitButton = button;
        }
        self.nowButton.selected = YES;
    }
}

- (UITextField *)liveTimeTf {
    if (!_liveTimeTf) {
        _liveTimeTf = [[UITextField alloc]initWithFrame:CGRectMake(30, 150, 200, 30)];
        _liveTimeTf.font = [UIFont systemFontOfSize:15];
        _liveTimeTf.textColor = [UIColor grayColor];
        _liveTimeTf.backgroundColor = [UIColor whiteColor];
        _liveTimeTf.textAlignment = NSTextAlignmentLeft;
        _liveTimeTf.placeholder = @"请选择日期";
        _liveTimeTf.hidden = YES;
        [self.view addSubview:_liveTimeTf];
        
        [_liveTimeTf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.waitButton.mas_right);
            make.top.equalTo(self.waitButton.mas_bottom).offset(8);
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(30);
        }];
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"choose_date"]];
        [_liveTimeTf addSubview:image];
        [image mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.liveTimeTf);
            make.right.equalTo (self.liveTimeTf.mas_right).offset(-15);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showDatePicker)];
        _liveTimeTf.userInteractionEnabled = YES;
        [_liveTimeTf addGestureRecognizer:tap];
        
    }
    return _liveTimeTf;
}

- (void)showDatePicker {
    __weak typeof(self)weakSelf = self;
    DateTimePickerView *dateTimePickerView = [[DateTimePickerView alloc] initWithDatePickerMode:DatePickerDateHourMinuteMode defaultDateTime:[[NSDate alloc]initWithTimeIntervalSinceNow:1000]];
    dateTimePickerView.clickedOkBtn = ^(NSString * datetimeStr){
        NSLog(@"%@", datetimeStr);
        weakSelf.liveTimeTf.text = datetimeStr;
    };
    if (dateTimePickerView) {
        [self.view addSubview:dateTimePickerView];
        [dateTimePickerView showHcdDateTimePicker];
    }
}

- (void)livebeginSelect:(UIButton *)btn {
    if (btn == self.waitButton) {
        self.waitButton.selected = !self.waitButton.selected;
        self.nowButton.selected = !self.waitButton.selected;
    } else if (btn == self.nowButton) {
        self.nowButton.selected = !self.nowButton.selected;
        self.waitButton.selected = !self.nowButton.selected;
    }
    
    self.liveTimeTf.hidden = !self.waitButton.selected;
    
}

- (void)startButton {
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_W - 200)/2, SCREEN_H - 100, 200, 40)];
    button.clipsToBounds = YES;
    button.layer.cornerRadius = 20;
    [button setImage:[UIImage imageNamed:@"begin_live"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(createLive) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)turnAroundButton {
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_W - 200)/2 + 20 + 200, SCREEN_H - 100, 40, 40)];
    [button setImage:[UIImage imageNamed:@"create_turn_around"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(turnAroundButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)closeButton {
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_W - 40, 50, 20, 20)];
    [button setImage:[UIImage imageNamed:@"icon_quit"] forState:UIControlStateNormal];
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
    if (self.commendTf.text.length > 0) {
        params.notice = self.commendTf.text;
    }
    params.cover_url = LIVE_User_avatar;
    if (self.waitButton.selected == YES) {
        params.start_at = [self.liveTimeTf.text stringByAppendingString:@":00"];
    }
    
//    params.extension = @"";
    
    [[QLive getRooms] createRoom:params callBack:^(QNLiveRoomInfo * _Nonnull roomInfo) {

        BeautyLiveViewController *vc = [BeautyLiveViewController new];
        vc.roomInfo = roomInfo;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }];
}

@end
