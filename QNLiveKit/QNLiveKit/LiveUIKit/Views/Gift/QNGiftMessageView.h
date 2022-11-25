//
//  QNGiftMesageView.h
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNIMMessageObject;

@interface QNGiftMessageView : UIView

- (void)showGiftWithMessage:(QNIMMessageObject *)message complete:(void (^)(void))complete;

- (void)showGiftMessage:(QNIMMessageObject *)message;
@end

NS_ASSUME_NONNULL_END
