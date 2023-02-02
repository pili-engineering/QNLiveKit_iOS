//
//  QNLivePullClient.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import "QNLivePullClient.h"
#import "QNLiveRoomInfo.h"
#import "QLiveNetworkUtil.h"
#import "QNLiveUser.h"
#import "QNLiveRoomInfo.h"
#import <PLPlayerKit/PLPlayerKit.h>
#import "QLinkMicService.h"

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
    [QLiveNetworkUtil postRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        
        QNLiveRoomInfo *model = [QNLiveRoomInfo mj_objectWithKeyValues:responseData];
        self.roomInfo = model;
        callBack(model);

        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}

//离开直播
- (void)leaveRoom:(NSString *)roomID{
    
    NSString *action = [NSString stringWithFormat:@"client/live/room/user/%@",roomID];
    [QLiveNetworkUtil deleteRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        
        } failure:^(NSError * _Nonnull error) {
        }];
}

- (void)play:(UIView *)view url:(NSString *)url {
    
    PLPlayerOption *option = [PLPlayerOption defaultOption];
    PLPlayFormat format = kPLPLAY_FORMAT_UnKnown;
    
    [option setOptionValue:@(format) forKey:PLPlayerOptionKeyVideoPreferFormat];
    [option setOptionValue:@(kPLLogError) forKey:PLPlayerOptionKeyLogLevel];
    
    self.player = [PLPlayer playerWithURL:[NSURL URLWithString:url] option:option];
    [view insertSubview:self.player.playerView atIndex:2];
    [self.player.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.player play];
}

- (void)stopPlay {
    [self.player stop];
    [self.player.playerView  removeFromSuperview];
}


@end
