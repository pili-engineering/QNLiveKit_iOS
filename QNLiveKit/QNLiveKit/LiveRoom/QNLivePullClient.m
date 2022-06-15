//
//  QNLivePullClient.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import "QNLivePullClient.h"
#import "QNLiveRoomInfo.h"
#import "QRenderView.h"
#import "QNLiveNetworkUtil.h"
#import "QNLiveUser.h"
#import "QNLiveRoomInfo.h"
#import <PLPlayerKit/PLPlayerKit.h>

@interface QNLivePullClient ()

@property (nonatomic, strong) PLPlayer *player;

@end

@implementation QNLivePullClient

+ (instancetype)createLivePullClient {
    static QNLivePullClient *pullClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        pullClient = [[QNLivePullClient alloc]init];
    });
    return pullClient;
}

- (void)destroy {
    
}

//加入直播
- (void)joinRoom:(NSString *)roomID callBack:(void (^)(QNLiveRoomInfo * _Nullable))callBack {
    
    NSString *action = [NSString stringWithFormat:@"client/live/room/user/%@",roomID];
    [QNLiveNetworkUtil postRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        
        QNLiveRoomInfo *model = [QNLiveRoomInfo mj_objectWithKeyValues:responseData];
        callBack(model);
        [self setPlayerWithUrlStr:model.rtmp_url];
        
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}

//离开直播
- (void)leaveRoom:(NSString *)roomID callBack:(void (^)(void))callBack {
    
    NSString *action = [NSString stringWithFormat:@"client//live/room/user/%@",roomID];
    [QNLiveNetworkUtil deleteRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        
        callBack();
        } failure:^(NSError * _Nonnull error) {
            callBack();
        }];
}

- (void)play:(UIView *)view {
    [view addSubview:self.player.playerView];
    [self.player.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.player play];
}

- (void)stopPlay {
    [self.player stop];
    [self.player.playerView  removeFromSuperview];
}

- (void)setPlayerWithUrlStr:(NSString *)urlStr {
    
    NSURL *url = [NSURL URLWithString:urlStr];
    PLPlayerOption *option = [PLPlayerOption defaultOption];
    PLPlayFormat format = kPLPLAY_FORMAT_UnKnown;
    
    [option setOptionValue:@(format) forKey:PLPlayerOptionKeyVideoPreferFormat];
    [option setOptionValue:@(kPLLogNone) forKey:PLPlayerOptionKeyLogLevel];
    
    self.player = [PLPlayer playerWithURL:url option:option];
    
}

@end
