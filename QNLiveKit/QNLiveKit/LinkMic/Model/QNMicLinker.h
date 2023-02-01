//
//  QNMicLinker.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>
#import "QNLiveUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNMicLinker : NSObject

@property (nonatomic, strong)QNLiveUser *user;
//连麦用户所在房间ID
@property (nonatomic, copy)NSString *userRoomId;
//扩展字段
@property (nonatomic, copy)NSString *extends;
//是否开麦克风
@property (nonatomic, assign)BOOL mic;
//是否开摄像头
@property (nonatomic, assign)BOOL camera;
//流
@property (nonatomic, strong) QNTrack *track;

@end


// 由于 json 未统一
@interface QNMicLinker2 : QNMicLinker

@property (nonatomic, copy)NSString *uid;

@end

NS_ASSUME_NONNULL_END
