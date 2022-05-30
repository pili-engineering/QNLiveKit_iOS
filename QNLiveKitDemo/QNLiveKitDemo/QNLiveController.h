//
//  QNLiveController.h
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/30.
//

#import <UIKit/UIKit.h>
#import "QNBaseRTCController.h"

NS_ASSUME_NONNULL_BEGIN

@class QNLiveRoomInfo;
@interface QNLiveController : QNBaseRTCController
@property (nonatomic,strong) QNLiveRoomInfo *roomInfo;
@end

NS_ASSUME_NONNULL_END
