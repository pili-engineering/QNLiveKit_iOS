//
//  QNDanmakuService.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import <QNLiveKit/QNLiveKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DanmakuModel;

@protocol QNDanmakuServiceListener <NSObject>
//收到弹幕消息  @return 是否分发到排队显示逻辑
- (BOOL)onReceiveDanmaku:(DanmakuModel *)model;

@end

@interface QNDanmakuService : QNLiveService

//添加监听
- (void)addDanmakuServiceListener:(id<QNDanmakuServiceListener>)listener;

//移除监听
- (void)removeDanmakuServiceListener:(id<QNDanmakuServiceListener>)listener;

//发送弹幕消息
- (void)sendDanmaku:(NSString *)msg extensions:(NSString *)extensions callBack:(void (^)(DanmakuModel * model))callBack;

@end

NS_ASSUME_NONNULL_END
