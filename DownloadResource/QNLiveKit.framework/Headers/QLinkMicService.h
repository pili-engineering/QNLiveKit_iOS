//
//  QLinkMicService.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <UIKit/UIKit.h>
#import "QNLiveService.h"
#import "QNMicLinker.h"
#import "QRenderView.h"
#import "QNLiveRoomInfo.h"

NS_ASSUME_NONNULL_BEGIN

//连麦服务
@interface QLinkMicService : QNLiveService

//获取当前房间所有连麦用户
- (void)getAllLinker:(void (^)(NSArray <QNMicLinker *> *list))callBack;

//上麦
- (void)onMic:(BOOL)mic camera:(BOOL)camera extends:(nullable NSDictionary *)extends;

//下麦
- (void)downMic;

//获取用户麦位状态
- (void)getMicStatus:(NSString *)uid type:(NSString *)type callBack:(nullable void (^)(void))callBack;

//踢人
- (void)kickOutUser:(NSString *)uid msg:(nullable NSString *)msg callBack:(nullable void (^)(QNMicLinker * _Nullable))callBack ;

//开关麦 type:mic/camera  flag:on/off
- (void)updateMicStatusType:(NSString *)type flag:(BOOL)flag;

//更新扩展字段
- (void)updateExtension:(NSString *)extension callBack:(nullable void (^)(void))callBack;

@end

NS_ASSUME_NONNULL_END
