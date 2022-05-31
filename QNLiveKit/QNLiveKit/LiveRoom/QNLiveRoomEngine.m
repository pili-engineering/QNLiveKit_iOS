//
//  QNLiveRoomEngine.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import "QNLiveRoomEngine.h"
#import "QNCreateRoomParam.h"
#import "QNLiveRoomInfo.h"
#import "QNDeleteRoomParam.h"
#import "QNLiveUser.h"
#import "QNLiveNetworkUtil.h"

@interface QNLiveRoomEngine ()


@end

@implementation QNLiveRoomEngine

+ (void)initWithToken:(NSString *)token {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:Live_Token];
    [defaults synchronize];
}


//创建房间
+ (void)createRoom:(QNCreateRoomParam *)param callBack:(void (^)(QNLiveRoomInfo * roomInfo))callBack {
    
    [QNLiveNetworkUtil postRequestWithAction:@"client/live/room/instance" params:param.mj_keyValues success:^(NSDictionary * _Nonnull responseData) {
            
        QNLiveRoomInfo *model = [QNLiveRoomInfo mj_objectWithKeyValues:responseData];
        callBack(model);

        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}

//删除房间
+ (void)deleteRoom:(NSString *)liveId callBack:(void (^)(void))callBack {
    NSString *action = [NSString stringWithFormat:@"client/live/room/instance/%@",liveId];
    [QNLiveNetworkUtil deleteRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        callBack();
        } failure:^(NSError * _Nonnull error) {
            callBack();
        }];
}

//直播列表
+ (void)listRoomWithPageNumber:(NSInteger)pageNumber pageSize:(NSInteger)pageSize callBack:(void (^)(NSArray<QNLiveRoomInfo *> * list))callBack {
    NSString *action = [NSString stringWithFormat:@"client/live/room/list?page_num=%ld&page_size=%ld",pageNumber,pageSize];
    [QNLiveNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        NSArray <QNLiveRoomInfo *> *list = [QNLiveRoomInfo mj_objectArrayWithKeyValuesArray:responseData[@"list"]];
        callBack(list);
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}


@end
