//
//  GoodSellItemCell.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GoodsModel;

@interface GoodSellItemCell : UITableViewCell

- (void)updateWithModel:(GoodsModel *)itemModel;
//点击下架商品
@property (nonatomic, copy) void (^takeDownClickedBlock)(GoodsModel *itemModel);
//讲解商品
@property (nonatomic, copy) void (^explainClickedBlock)(GoodsModel *itemModel);

@end

NS_ASSUME_NONNULL_END
