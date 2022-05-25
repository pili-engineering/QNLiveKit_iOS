//
//  QNLiveService.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNLiveRoomClient;

@interface QNLiveService : NSObject

- (void)attachRoomClient:(QNLiveRoomClient *)client;

@end

NS_ASSUME_NONNULL_END
