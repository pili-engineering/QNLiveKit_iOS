//
//  QNGiftMessagePannel.h
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNIMMessageObject;

@interface QNGiftMessagePannel : UIView

- (void)showGiftMessage:(QNIMMessageObject *)message;

@end

NS_ASSUME_NONNULL_END
