//
//  QPKService.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import <QNLiveKit/QNLiveKit.h>
#import "QNLiveService.h"

NS_ASSUME_NONNULL_BEGIN

@class QNPKSession,QRenderView;


@interface QPKService : QNLiveService

- (instancetype)initWithRoomId:(NSString *)roomId ;

//开始pk 
- (void)startWithReceiverRoomId:(NSString *)receiverRoomId receiverUid:(NSString *)receiverUid extensions:(NSString *)extensions callBack:(nullable void (^)(QNPKSession *_Nullable pkSession))callBack;

//获取pk token
- (void)getPKToken:(NSString *)relayID callBack:(nullable void (^)(QNPKSession * _Nullable pkSession))callBack;

//通知服务端跨房完成
- (void)PKStartedWithRelayID:(NSString *)relayID;

//结束pk
- (void)stopWithRelayID:(NSString *)relayID callBack:(nullable void (^)(void))callBack;

@end

NS_ASSUME_NONNULL_END
