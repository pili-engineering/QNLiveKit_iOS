//
//  GoodBuyItemCell.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GoodsModel;

@interface GoodBuyItemCell : UITableViewCell

- (void)updateWithModel:(GoodsModel *)itemModel;
//点击购买商品
@property (nonatomic, copy) void (^buyClickedBlock)(GoodsModel *itemModel);

@end

NS_ASSUME_NONNULL_END
