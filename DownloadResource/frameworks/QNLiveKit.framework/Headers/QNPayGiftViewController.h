//
//  QNPayGiftViewController.h
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNPayGiftViewController : UIViewController

@property (nonatomic, assign) NSInteger amount;

- (instancetype)initWithComplete:(void (^)(NSInteger amount))complete;

@end

NS_ASSUME_NONNULL_END
