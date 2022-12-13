//
//  QNGiftService.h
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/23.
//

#import <Foundation/Foundation.h>
#import "QNGiftModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNGiftService : NSObject

+ (instancetype)sharedInstance;

- (void)getGiftModelsByType:(NSInteger)type complete:(void (^)(NSArray<QNGiftModel *>* giftModels))complete;

- (void)getGiftModelById:(NSInteger)giftID complete:(void (^)(QNGiftModel *giftModel))complete;

@end

NS_ASSUME_NONNULL_END
