//
//  QStatisticalService.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/9/9.
//

#import "QStatisticalService.h"
#import "QRoomDataModel.h"
#import "QLiveNetworkUtil.h"
#import "QRoomDataModel.h"

@implementation QStatisticalService

//上报评论互动
- (void)uploadComments {
    QRoomDataModel *model = [QRoomDataModel new];
    model.live_id = self.roomInfo.live_id;
    model.user_id = LIVE_User_id;
    model.type = QRoomDataTypeComment;
    model.count = 1;
    [self roomDataStatistical:@[model.mj_keyValues]];
}

//上报商品点击
- (void)uploadGoodClick {
    QRoomDataModel *model = [QRoomDataModel new];
    model.live_id = self.roomInfo.live_id;
    model.user_id = LIVE_User_id;
    model.type = QRoomDataTypeGoodClick;
    model.count = 1;
    [self roomDataStatistical:@[model.mj_keyValues]];
}

//房间数据上报
- (void)roomDataStatistical:(NSArray *)roomData {
    NSDictionary *params = @{@"Data" : roomData.mj_keyValues};
    [QLiveNetworkUtil postRequestWithAction:@"client/stats/singleLive" params:params success:^(NSDictionary * _Nonnull responseData) {
        } failure:^(NSError * _Nonnull error) {
        }];
}

//获取房间统计数据
- (void)getRoomData:(void (^)(NSArray <QRoomDataModel *> *model))callBack {
    NSString *action = [NSString stringWithFormat:@"client/stats/singleLive/%@",self.roomInfo.live_id];
    [QLiveNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        NSArray <QRoomDataModel *> *list = [QRoomDataModel mj_objectArrayWithKeyValuesArray:responseData[@"info"]];
        callBack(list);
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}

@end
