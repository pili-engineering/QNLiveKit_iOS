//
//  GoodsOperationCell.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GoodsModel;

//商品批量操作cell
@interface GoodsOperationCell : UITableViewCell

@property (nonatomic, copy) void (^selectButtonClickedBlock)(GoodsModel *itemModel);

- (void)updateWithModel:(GoodsModel *)itemModel;

@end

NS_ASSUME_NONNULL_END
