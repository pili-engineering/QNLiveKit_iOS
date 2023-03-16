//
//  QNBeautyManager.h
//  QNLiveUIKit
//
//  Created by 孙慕 on 2023/2/17.
//

#import <Foundation/Foundation.h>
#import <PLSTArEffects/PLSTArEffects.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNBeautyManager : NSObject

+ (QNBeautyManager *)shardManager;

- (void)initSuccess:(void (^)(BOOL state))succes;

-(PLSTEffectManager *)getEffectManager;

-(PLSTDetector *)getDetector;
@end

NS_ASSUME_NONNULL_END
