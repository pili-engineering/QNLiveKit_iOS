//
//  WatchBottomMoreView.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/10/19.
//

#import <UIKit/UIKit.h>
#import "ImageButtonView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^GiftBlock)(void);
typedef void (^ApplyLinkBlock)(void);


@interface WatchBottomMoreView : UIView
@property (nonatomic, strong)ImageButtonView *gift;
@property (nonatomic, strong)ImageButtonView *link;

@property (nonatomic, copy)GiftBlock giftBlock;

@property (nonatomic, copy)ApplyLinkBlock applyLinkBlock;

@end

NS_ASSUME_NONNULL_END
