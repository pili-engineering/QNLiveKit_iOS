//
//  GoodStatusView.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GoodStatusView : UIView

@property (nonatomic, copy) void (^typeClickedBlock)(QLiveGoodsStatus status);

- (void)updateWithModel:(NSArray <GoodsModel *> *)itemModels;

@end

NS_ASSUME_NONNULL_END
