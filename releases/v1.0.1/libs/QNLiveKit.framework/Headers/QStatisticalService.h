//
//  QStatisticalService.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/9/9.
//

#import <QNLiveKit/QNLiveKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QRoomDataModel;
//统计信息服务
@interface QStatisticalService : QNLiveService

//房间数据上报
- (void)roomDataStatistical:(NSArray *)roomData;

//获取房间统计数据
- (void)getRoomData:(void (^)(NSArray <QRoomDataModel *> *model))callBack;

//上报评论互动
- (void)uploadComments;

//上报商品点击
- (void)uploadGoodClick;

@end

NS_ASSUME_NONNULL_END
