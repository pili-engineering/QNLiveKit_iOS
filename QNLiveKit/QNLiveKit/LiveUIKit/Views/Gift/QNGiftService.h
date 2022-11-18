//
//  QGiftService.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/11/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNGiftService : NSObject

- (void)sendGift:(id)giftModel callBack:(nullable void (^)(void))callBack;

@end

NS_ASSUME_NONNULL_END
