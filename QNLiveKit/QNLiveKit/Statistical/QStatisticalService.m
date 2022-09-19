//
//  QStatisticalService.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/9/9.
//

#import "QStatisticalService.h"
#import "QRoomDataModel.h"
#import "QLiveNetworkUtil.h"

@implementation QStatisticalService

//房间数据上报
- (void)roomDataStatistical:(NSArray <QRoomDataModel *> *)roomData {
    NSDictionary *params = roomData.mj_keyValues;
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
