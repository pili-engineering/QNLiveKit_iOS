//
//  CreateBeautyLiveController.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/18.
//

#import "CreateBeautyLiveController.h"
#import "QRenderView.h"
#import "QLive.h"
#import "QLiveController.h"
#import "QNCreateRoomParam.h"
#import "QNLivePushClient.h"
#import "BeautyLiveViewController.h"

@interface CreateBeautyLiveController () <QNLocalVideoTrackDelegate>
@property (nonatomic, strong) UITextField *titleTf;
@end

@implementation CreateBeautyLiveController

+ (void)initialize {
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SENSEME" ofType:@"lic"];
    NSData* license = [NSData dataWithContentsOfFile:path];
    [[STDefaultSetting sharedInstace] checkActiveCodeWithData:license];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[QLive createPusherClient] enableCamera:nil renderView:self.preview];
    [self setupSenseAR];
    [[QLive createPusherClient] setVideoFrameListener:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"live_bg"]];
    bg.frame = self.view.frame;
    [self.view addSubview:bg];
    
    [bg addSubview:self.preview];
        
    [self titleTf];
    [self beautyButton];
    [self startButton];
    [self turnAroundButton];
    [self closeButton];
    
}


- (void)localVideoTrack:(QNLocalVideoTrack *)localVideoTrack didGetPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    
    QNCameraVideoTrack *track = (QNCameraVideoTrack *)localVideoTrack;
    
    static st_mobile_human_action_t result;
    static st_mobile_animal_face_t animalResult;
    QNAllResult res;
    memset(&res, 0, sizeof(res));
    res.animal_result = &animalResult;
    res.humanResult = &result;
    
    [self updateFirstEnterUI];
    
    QNDetectConfig detectConfig;
    memset(&detectConfig, 0, sizeof(QNDetectConfig));
    detectConfig.humanConfig = [self.effectManager getEffectDetectConfig];
    detectConfig.animalConfig = [self.effectManager getEffectAnimalDetectConfig];
    
    [self.detector detect:pixelBuffer cameraOrientation:track.videoOrientation detectConfig:detectConfig allResult:&res];
    [self.effectManager processBuffer:pixelBuffer cameraOrientation:track.videoOrientation detectResult:&res];
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

- (void)beautyButtonClick {
    [self clickBottomViewButton:self.beautyBtn];
}

- (void)turnAroundButtonClick {
    [self clickBottomViewButton:self.specialEffectsBtn];
}

- (void)beautyButton {
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_W - 200)/2 - 60, SCREEN_H - 100, 40, 40)];
    [button setImage:[UIImage imageNamed:@"create_beauty"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(beautyButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
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
//    params.notice = @"";
    params.cover_url = QN_User_avatar;
//    params.extension = @"";
    
    [[QLive getRooms] createRoom:params callBack:^(QNLiveRoomInfo * _Nonnull roomInfo) {

        BeautyLiveViewController *vc = [BeautyLiveViewController new];
        vc.roomInfo = roomInfo;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }];
}

@end
