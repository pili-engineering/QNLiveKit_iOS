//
//  QNLiveService.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNLiveRoomInfo;

//service基类

@interface QNLiveService : NSObject

@property (nonatomic, strong) QNLiveRoomInfo *roomInfo;

@end

NS_ASSUME_NONNULL_END
