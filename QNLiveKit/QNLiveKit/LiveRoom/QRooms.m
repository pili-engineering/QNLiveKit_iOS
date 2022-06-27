//
//  QRooms.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/14.
//

#import "QRooms.h"
#import "QNCreateRoomParam.h"
#import "QNLiveRoomInfo.h"
#import "QLiveNetworkUtil.h"


@implementation QRooms

//创建房间
- (void)createRoom:(QNCreateRoomParam *)param callBack:(nullable void (^)(QNLiveRoomInfo * roomInfo))callBack {
    
    [QLiveNetworkUtil postRequestWithAction:@"client/live/room/instance" params:param.mj_keyValues success:^(NSDictionary * _Nonnull responseData) {
            
        QNLiveRoomInfo *model = [QNLiveRoomInfo mj_objectWithKeyValues:responseData];
        callBack(model);

        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}

//删除房间
- (void)deleteRoom:(NSString *)liveId callBack:(void (^)(void))callBack {
    NSString *action = [NSString stringWithFormat:@"client/live/room/instance/%@",liveId];
    [QLiveNetworkUtil deleteRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        callBack();
        } failure:^(NSError * _Nonnull error) {
            callBack();
        }];
}

//直播列表
- (void)listRoom:(NSInteger)pageNumber pageSize:(NSInteger)pageSize callBack:(nullable void (^)(NSArray<QNLiveRoomInfo *> * list))callBack {
    NSString *action = [NSString stringWithFormat:@"client/live/room/list?page_num=%ld&page_size=%ld",pageNumber,pageSize];
    [QLiveNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        NSArray <QNLiveRoomInfo *> *list = [QNLiveRoomInfo mj_objectArrayWithKeyValuesArray:responseData[@"list"]];
        callBack(list);
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}


//获取房间详情
- (void)getRoomInfo:(NSString *)roomID callBack:(nullable void (^)(QNLiveRoomInfo *roomInfo))callBack {
    
    NSString *action = [NSString stringWithFormat:@"client/live/room/info/%@",roomID];
    [QLiveNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        QNLiveRoomInfo *model = [QNLiveRoomInfo mj_objectWithKeyValues:responseData];
        callBack(model);
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}
@end
