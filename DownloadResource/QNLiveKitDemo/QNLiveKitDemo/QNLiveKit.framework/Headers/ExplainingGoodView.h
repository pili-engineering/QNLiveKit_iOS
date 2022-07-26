//
//  ExplainingGoodView.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/14.
//

#import "QLiveView.h"

NS_ASSUME_NONNULL_BEGIN

@class GoodsModel;

//观众页 正在讲解商品view
@interface ExplainingGoodView : QLiveView

- (void)updateWithModel:(GoodsModel *)itemModel;
//点击购买商品
@property (nonatomic, copy) void (^buyClickedBlock)(GoodsModel *itemModel);

@end

NS_ASSUME_NONNULL_END
