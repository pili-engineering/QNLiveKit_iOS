//
//  QNDeleteRoomParam.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 删除房间参数
@interface QNDeleteRoomParam : NSObject

@property (nonatomic, copy)NSString *app_id;

@property (nonatomic, copy)NSString *live_id;

@end

NS_ASSUME_NONNULL_END
