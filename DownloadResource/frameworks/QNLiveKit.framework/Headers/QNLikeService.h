//
//  QNLikeService.h
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 点赞成功回调
 * @param count 我自己在直播间的点赞数
 * @param total 直播间总点赞数
 */
typedef void (^GiveLikeCompleteBlock)(NSInteger count, NSInteger total);

@interface QNLikeService : NSObject

+ (instancetype)sharedInstance;

- (void)giveLike:(NSString *)liveId
           count:(NSInteger)count
        complete:(GiveLikeCompleteBlock)complete
         failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
