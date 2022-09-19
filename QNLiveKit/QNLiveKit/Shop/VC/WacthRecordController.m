//
//  WacthRecordController.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/9/19.
//

#import "WacthRecordController.h"
#import "GoodsModel.h"
#import <PLPlayerKit/PLPlayerKit.h>
#import "RoomHostView.h"
#import "QNLiveRoomInfo.h"
#import "OnlineUserView.h"
#import "ExplainingGoodView.h"
@interface WacthRecordController ()<PLPlayerDelegate>
@property (nonatomic, strong) GoodsModel *itemModel;
@property (nonatomic, strong) PLPlayer *player;
@property (nonatomic, strong) RoomHostView *roomHostView;
@property (nonatomic, strong) OnlineUserView *onlineUserView;
@property (nonatomic, strong) QNLiveRoomInfo *roomInfo;
@property (nonatomic, strong) ExplainingGoodView *goodView;
@property (nonatomic, strong) UIButton *backLiveButton;

@end

@implementation WacthRecordController

- (instancetype)initWithModel:(GoodsModel *)model roomInfo:(QNLiveRoomInfo *)roomInfo{
    if (self = [super init]) {
        self.itemModel = model;
        self.roomInfo = roomInfo;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self playWithUrl:self.itemModel.record.record_url];
    [self roomHostView];
    [self onlineUserView];
    [self goodView];
    [self backLiveButton];    
}

- (void)backLive {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)playWithUrl:(NSString *)url {
    PLPlayerOption *option = [PLPlayerOption defaultOption];
    PLPlayFormat format = kPLPLAY_FORMAT_UnKnown;
    
    [option setOptionValue:@(format) forKey:PLPlayerOptionKeyVideoPreferFormat];
    [option setOptionValue:@(kPLLogNone) forKey:PLPlayerOptionKeyLogLevel];
    
    self.player = [PLPlayer playerWithURL:[NSURL URLWithString:url] option:option];
    [self.view addSubview:self.player.playerView];
    self.player.playerView.frame = self.view.frame;
   
    self.player.playerView.backgroundColor = [UIColor clearColor];
    self.player.playerView.contentMode = UIViewContentModeScaleAspectFill;
    self.player.delegate = self;
    self.player.delegateQueue = dispatch_get_main_queue();
    [self.player play];
}

- (RoomHostView *)roomHostView {
    if (!_roomHostView) {
        _roomHostView = [[RoomHostView alloc]initWithFrame:CGRectMake(20, 60, 135, 40)];
        [self.view addSubview:_roomHostView];
        [_roomHostView updateWith:self.roomInfo];;
        _roomHostView.clickBlock = ^(BOOL selected){
            NSLog(@"点击了房主头像");
        };
    }
    return _roomHostView;
}

- (OnlineUserView *)onlineUserView {
    if (!_onlineUserView) {
        _onlineUserView = [[OnlineUserView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 150, 60, 150, 60)];
        [self.view addSubview:_onlineUserView];
        [_onlineUserView updateWith:self.roomInfo];
        _onlineUserView.clickBlock = ^(BOOL selected){
            NSLog(@"点击了在线人数");
        };
    }
    return _onlineUserView;
}

- (ExplainingGoodView *)goodView {
    if (!_goodView) {
        _goodView = [[ExplainingGoodView alloc]initWithFrame:CGRectMake(SCREEN_W - 130, SCREEN_H - 280, 115, 170)];
        __weak typeof(self)weakSelf = self;
        _goodView.buyClickedBlock = ^(GoodsModel * _Nonnull itemModel) {
            if (weakSelf.buyClickedBlock) {
                weakSelf.buyClickedBlock(itemModel);
            }
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        };
        [_goodView updateWithModel:self.itemModel];
        [self.view addSubview:_goodView];
    }
    return _goodView;
}

- (UIButton *)backLiveButton {
    if (!_backLiveButton) {
        _backLiveButton = [[UIButton alloc]init];
        [_backLiveButton setImage:[UIImage imageNamed:@"back_live"] forState:UIControlStateNormal];
        [self.view addSubview:_backLiveButton];
        [_backLiveButton addTarget:self action:@selector(backLive) forControlEvents:UIControlEventTouchUpInside];
        [_backLiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-70);
        }];
    }
    return _backLiveButton;
}

@end
