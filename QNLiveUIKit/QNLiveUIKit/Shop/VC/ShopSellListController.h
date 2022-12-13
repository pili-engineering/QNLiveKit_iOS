//
//  ShopSellListController.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNLiveRoomInfo;

//商品列表页面(主播)
@interface ShopSellListController : UIViewController

- (instancetype)initWithLiveInfo:(QNLiveRoomInfo *)liveInfo;

@end

NS_ASSUME_NONNULL_END
