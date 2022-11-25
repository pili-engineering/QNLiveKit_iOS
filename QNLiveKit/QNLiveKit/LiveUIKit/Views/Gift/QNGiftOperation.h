//
//  QNGiftOperation.h
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNIMMessageObject, QNGiftMessageView;

@interface QNGiftOperation : NSOperation

- (instancetype)initWithMessage:(QNIMMessageObject *)message view:(QNGiftMessageView *)view;

@end

NS_ASSUME_NONNULL_END
